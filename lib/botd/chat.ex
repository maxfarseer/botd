defmodule Botd.Chat do
  @moduledoc """
  This module is responsible for handling the Telegram chat interactions.
  """

  alias Botd.Accounts
  alias Botd.Suggestions
  require Logger

  @type step ::
          :waiting_for_start
          | :selected_action
          | :selected_add_person
          | :waiting_for_name
          | :waiting_for_death_date
          | :waiting_for_reason
          | :waiting_for_photo
          | :waiting_for_gallery_photos
          | :finished

  @type t :: %__MODULE__{
          chat_id: integer(),
          step: step(),
          name: String.t() | nil,
          death_date: Date.t() | nil,
          reason: String.t() | nil,
          photo_url: String.t() | nil,
          photos: list()
        }

  defstruct chat_id: nil,
            step: :waiting_for_start,
            name: nil,
            death_date: nil,
            reason: nil,
            photo_url: nil,
            photos: []

  def init_state do
    %__MODULE__{}
  end

  @state_transitions %{
    waiting_for_start: :selected_action,
    selected_add_person: :waiting_for_name,
    waiting_for_name: :waiting_for_death_date,
    waiting_for_death_date: :waiting_for_reason,
    waiting_for_reason: :waiting_for_photo,
    waiting_for_photo: :waiting_for_gallery_photos,
    waiting_for_gallery_photos: :finished
  }
  defp make_next_step(step), do: Map.get(@state_transitions, step, :finished)

  defp handle_waiting_for_start(key, %{"message" => %{"text" => "/start"}}, chat) do
    Telegram.Api.request(key, "sendMessage",
      chat_id: chat.chat_id,
      text: "Выберите действие",
      reply_markup: {:json, start_menu()}
    )

    next_step = make_next_step(:waiting_for_start)
    %__MODULE__{chat | step: next_step}
  end

  defp handle_waiting_for_start(key, _update, chat) do
    answer_on_message(key, chat.chat_id, "Для начала работы введите /start")
    chat
  end

  defp handle_selected_action(key, %{"message" => %{"text" => "Добавить"}}, chat) do
    answer_on_message(key, chat.chat_id, "Укажите имя")
    next_step = make_next_step(:selected_add_person)
    %__MODULE__{chat | step: next_step}
  end

  defp handle_selected_action(key, _update, chat) do
    answer_on_message(key, chat.chat_id, "В данный момент доступно только добавление")
    chat
  end

  defp handle_waiting_for_name(key, update, chat) do
    name = get_in(update, ["message", "text"])
    next_step = make_next_step(:waiting_for_name)

    answer_on_message(key, chat.chat_id, "Укажите дату смерти")

    %__MODULE__{chat | step: next_step, name: name}
  end

  defp handle_waiting_for_death_date(key, update, chat) do
    death_date = get_in(update, ["message", "text"])
    {:ok, parsed_date} = Date.from_iso8601(death_date)
    next_step = make_next_step(:waiting_for_death_date)

    answer_on_message(key, chat.chat_id, "Укажите причину")

    %__MODULE__{chat | step: next_step, death_date: parsed_date}
  end

  defp handle_waiting_for_reason(key, update, chat) do
    reason = get_in(update, ["message", "text"])
    next_step = make_next_step(:waiting_for_reason)

    answer_on_message(
      key,
      chat.chat_id,
      "Добавьте одно фото на аватар (вы сможете добавить остальные фото на следующем шаге)"
    )

    %__MODULE__{chat | step: next_step, reason: reason}
  end

  defp handle_photo_message(update) do
    case get_in(update, ["message", "photo"]) do
      nil ->
        {:error, "No photo found"}

      photos ->
        # take the last photo in the list (highest resolution)
        [%{"file_id" => file_id} | _] = Enum.reverse(photos)
        {:ok, file_id}
    end
  end

  defp get_file_url(key, file_id) do
    case Telegram.Api.request(key, "getFile", %{file_id: file_id}) do
      {:ok, %{"file_path" => file_path}} ->
        {:ok, "https://api.telegram.org/file/bot#{key}/#{file_path}"}

      {:error, reason} ->
        {:error, reason}

      _ ->
        {:error, "Failed to get file URL. Unexpected response."}
    end
  end

  defp send_total(key, chat) do
    chat_id = chat.chat_id

    total =
      %{
        "Имя" => chat.name,
        "Дата смерти" => chat.death_date,
        "Причина" => chat.reason
      }
      |> Enum.map_join("\n", fn {key, value} -> "#{key}: #{value}" end)

    answer_on_message(key, chat_id, total)

    Telegram.Api.request(key, "sendMessage",
      chat_id: chat_id,
      text: "Выберите действие",
      reply_markup: {:json, finished_menu()}
    )
  end

  defp handle_waiting_for_photo(key, update, chat) do
    with {:ok, file_id} <- handle_photo_message(update),
         {:ok, file_url} <- get_file_url(key, file_id),
         timestamp = DateTime.utc_now() |> DateTime.to_unix(),
         filename = "#{timestamp}_#{file_id}.jpg",
         {:ok, relative_path} <- Botd.FileHandler.download_and_save_file(file_url, filename) do
      answer_on_message(key, chat.chat_id, "Фото на аватар принято")

      Telegram.Api.request(key, "sendMessage",
        chat_id: chat.chat_id,
        text:
          "Сейчас вы можете загрузить фото для фотогалереи. Можно загрузить несколько фото сразу.",
        reply_markup: {:json, photo_menu()}
      )

      next_step = make_next_step(:waiting_for_photo)

      %__MODULE__{chat | photo_url: relative_path, step: next_step}
    else
      {:error, reason} when reason == "No photo found" ->
        answer_on_message(key, chat.chat_id, "Кажется, вы не отправили фото.")
        chat

      {:error, _reason} ->
        answer_on_message(key, chat.chat_id, "Проблема с загрузкой фото")
        chat
    end
  end

  defp handle_waiting_for_gallery_photos(
         key,
         %{"message" => %{"text" => "Я закончил добавление фото"}},
         chat
       ) do
    next_step = make_next_step(:waiting_for_many_photos)
    answer_on_message(key, chat.chat_id, "Вы ввели данные:")
    send_total(key, chat)
    %__MODULE__{chat | step: next_step}
  end

  defp handle_waiting_for_gallery_photos(key, update, chat) do
    with_photos = make_photo_set(update)

    case with_photos do
      {:ok, photoset} ->
        chat = %__MODULE__{chat | photos: [photoset | chat.photos]}
        chat

      {:error, reason} ->
        answer_on_message(key, chat.chat_id, "Ошибка при обработке фото: #{reason}")
        chat
    end
  end

  def process_photos(key, chat) do
    Enum.map(chat.photos, fn photoset ->
      case photoset[:large] do
        nil ->
          nil

        photo ->
          with {:ok, file_url} <- get_file_url(key, photo.file_id),
               timestamp = DateTime.utc_now() |> DateTime.to_unix(),
               filename = "#{timestamp}_#{photo.file_id}.jpg",
               {:ok, relative_path} <- Botd.FileHandler.download_and_save_file(file_url, filename) do
            Map.put(photo, :downloaded_path, relative_path)
          else
            _ -> photo
          end
      end
    end)
  end

  defp handle_finished(key, update, chat) do
    username = get_user_name(update)
    text = get_in(update, ["message", "text"])

    processed_photos = process_photos(key, chat)

    processed_photos_urls =
      Enum.map(processed_photos, fn photo ->
        if photo do
          photo.downloaded_path
        else
          nil
        end
      end)
      |> Enum.reject(&is_nil/1)

    case text do
      "Отправить" ->
        attributes =
          %{
            "name" => chat.name,
            "death_date" => chat.death_date,
            "cause_of_death" => chat.reason,
            "place" => "Hardcoded place",
            "telegram_username" => username,
            "photo_url" => chat.photo_url,
            "photos" => processed_photos_urls
          }

        user = Accounts.get_user_by_email("telegram@bot.com")

        case Suggestions.create_suggestion(attributes, user) do
          {:ok, _suggestion} ->
            answer_on_message(key, chat.chat_id, "Данные успешно отправлены на модерацию!")

          {:error, changeset} ->
            Logger.error("Error creating suggestion: #{inspect(changeset)}")
            answer_on_message(key, chat.chat_id, "Ошибка при отправке данных.")
        end

        chat

      "Внести новую запись в книгу" ->
        next_step = make_next_step(:waiting_for_start)
        %__MODULE__{chat | step: next_step}

      _ ->
        answer_on_message(key, chat.chat_id, "Действие в разработке")
        chat
    end
  end

  defp handle_unknown_state(chat) do
    Logger.warning("Unknown chat state: #{inspect(chat)}")
    chat
  end

  defp answer_on_message(key, chat_id, text) do
    Telegram.Api.request(key, "sendMessage",
      chat_id: chat_id,
      text: text
    )
  end

  defp start_menu do
    keyboard = [
      ["Добавить"]
    ]

    keyboard_markup = %{one_time_keyboard: true, keyboard: keyboard}

    keyboard_markup
  end

  defp photo_menu do
    keyboard = [
      ["Я закончил добавление фото"],
      ["Добавить еще фото"]
    ]

    keyboard_markup = %{one_time_keyboard: true, keyboard: keyboard}

    keyboard_markup
  end

  defp finished_menu do
    keyboard = [
      ["Отправить"],
      ["Редактировать", "Удалить"],
      ["Внести новую запись в книгу"]
    ]

    keyboard_markup = %{one_time_keyboard: true, keyboard: keyboard}

    keyboard_markup
  end

  def process_message_from_user(key, update, chat) do
    handlers = %{
      waiting_for_start: &handle_waiting_for_start/3,
      selected_action: &handle_selected_action/3,
      waiting_for_name: &handle_waiting_for_name/3,
      waiting_for_death_date: &handle_waiting_for_death_date/3,
      waiting_for_reason: &handle_waiting_for_reason/3,
      waiting_for_photo: &handle_waiting_for_photo/3,
      waiting_for_gallery_photos: &handle_waiting_for_gallery_photos/3,
      finished: &handle_finished/3
    }

    handler = Map.get(handlers, chat.step, &handle_unknown_state/1)

    if handler == (&handle_unknown_state/1) do
      handler.(chat)
    else
      handler.(key, update, chat)
    end
  end

  def get_user_name(%{"message" => message} = _update) do
    firstname = get_in(message, ["from", "first_name"])
    lastname = get_in(message, ["from", "last_name"])
    username = get_in(message, ["from", "username"])

    from =
      case {firstname, lastname, username} do
        {nil, _, username} -> username
        {firstname, nil, username} -> "#{firstname} (#{username})"
        {firstname, lastname, username} -> "#{firstname} #{lastname} (#{username})"
      end

    from
  end

  def make_photo_set(update) do
    case get_in(update, ["message", "photo"]) do
      nil ->
        {:error, "No photo found"}

      photos ->
        keys = [:tiny, :small, :medium, :large]

        photoset =
          photos
          |> Enum.take(4)
          |> Enum.with_index()
          |> Enum.reduce(%{}, fn {photo, idx}, acc ->
            key = Enum.at(keys, idx)

            Map.put(acc, key, %{
              file_id: photo["file_id"],
              file_size: photo["file_size"]
            })
          end)

        {:ok, photoset}
    end
  end
end
