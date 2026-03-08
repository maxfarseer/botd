defmodule Botd.VK do
  @moduledoc """
  Handles incoming VK community Callback API events.

  Processes suggested posts submitted to the VK community and creates
  suggestions in the app for moderation. Users must submit posts in the
  following template format:

      Имя: Иванов Иван Петрович
      Дата: 15.03.2024
      Место: Москва
      Причина: онкология

  Photos are attached directly to the VK post.
  """

  alias Botd.Accounts
  alias Botd.Suggestions
  require Logger

  @doc """
  Processes an incoming VK Callback API event payload (already decoded map).
  """
  def process_event(%{"type" => "wall_post_new", "object" => object}) do
    handle_wall_post_new(object)
  end

  def process_event(%{"type" => type}) do
    Logger.debug("VK: ignoring event type=#{type}")
    :ok
  end

  def process_event(payload) do
    Logger.warning("VK: received unexpected payload: #{inspect(payload)}")
    :ok
  end

  defp handle_wall_post_new(%{"post_type" => "suggest"} = object) do
    Logger.info("VK: received suggested post id=#{object["id"]}")
    parse_and_create(object)
  end

  defp handle_wall_post_new(%{"post_type" => type}) do
    Logger.debug("VK: ignoring wall post with post_type=#{type}")
    :ok
  end

  defp handle_wall_post_new(object) do
    Logger.debug("VK: ignoring wall post without post_type: #{inspect(object)}")
    :ok
  end

  defp parse_and_create(object) do
    text = object["text"] || ""
    group_id = object["owner_id"] || object["to_id"]
    post_id = object["id"]
    from_id = object["from_id"]

    with {:ok, name} <- extract_field(text, "Имя"),
         {:ok, death_date} <- extract_date(text) do
      place = extract_optional_field(text, "Место")
      cause = extract_optional_field(text, "Причина")
      photo_urls = extract_photo_urls(object)

      attrs = %{
        "name" => name,
        "death_date" => death_date,
        "place" => place,
        "notes" => cause,
        "photo_url" => List.first(photo_urls),
        "photos" => Enum.drop(photo_urls, 1),
        "source" => "vk",
        "vk_post_id" => post_id,
        "vk_owner_id" => group_id,
        "telegram_username" => "vk:#{from_id}"
      }

      user = Accounts.get_user_by_email("vk@bot.com")

      case Suggestions.create_suggestion(attrs, user) do
        {:ok, suggestion} ->
          Logger.info("VK: created suggestion id=#{suggestion.id} from VK post id=#{post_id}")

        {:error, changeset} ->
          Logger.error("VK: failed to create suggestion: #{inspect(changeset)}")
      end

      :ok
    else
      {:error, reason} ->
        Logger.warning("VK: skipping suggested post id=#{post_id} — parse failed: #{reason}")

        :ok
    end
  end

  defp extract_field(text, label) do
    pattern = Regex.compile!("#{label}:\\s*(.+)", "iu")

    case Regex.run(pattern, text) do
      [_, value] ->
        trimmed = String.trim(value)
        if trimmed == "", do: {:error, "#{label} is empty"}, else: {:ok, trimmed}

      nil ->
        {:error, "#{label} not found in post"}
    end
  end

  defp extract_optional_field(text, label) do
    case extract_field(text, label) do
      {:ok, value} -> value
      {:error, _} -> nil
    end
  end

  defp extract_date(text) do
    case extract_field(text, "Дата") do
      {:ok, raw_date} ->
        case parse_date(raw_date) do
          %Date{} = date -> {:ok, date}
          nil -> {:error, "invalid date format: #{raw_date}"}
        end

      error ->
        error
    end
  end

  defp parse_date(text) do
    text = String.trim(text)

    case Date.from_iso8601(text) do
      {:ok, date} -> date
      {:error, _} -> parse_ddmmyyyy(text)
    end
  end

  defp parse_ddmmyyyy(text) do
    case Regex.run(~r/^(\d{1,2})\.(\d{1,2})\.(\d{4})$/, text) do
      [_, day_s, month_s, year_s] ->
        with {day, ""} <- Integer.parse(day_s),
             {month, ""} <- Integer.parse(month_s),
             {year, ""} <- Integer.parse(year_s),
             {:ok, date} <- Date.new(year, month, day) do
          date
        else
          _ -> nil
        end

      _ ->
        nil
    end
  end

  defp extract_photo_urls(%{"attachments" => attachments}) when is_list(attachments) do
    attachments
    |> Enum.filter(&(&1["type"] == "photo"))
    |> Enum.map(&largest_photo_url(&1["photo"]))
    |> Enum.reject(&is_nil/1)
  end

  defp extract_photo_urls(_), do: []

  defp largest_photo_url(%{"sizes" => sizes}) when is_list(sizes) do
    sizes
    |> Enum.max_by(fn size -> size["width"] * size["height"] end, fn -> nil end)
    |> case do
      nil -> nil
      size -> size["url"]
    end
  end

  defp largest_photo_url(_), do: nil
end
