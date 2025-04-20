defmodule BotdWeb.SuggestionController do
  use BotdWeb, :controller
  alias Botd.ActivityLogs
  alias Botd.Suggestions
  alias Botd.Suggestions.Suggestion

  def new(conn, _params) do
    changeset = Suggestion.changeset(%Suggestion{}, %{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"suggestion" => suggestion_params}) do
    user = Pow.Plug.current_user(conn)

    case Suggestions.create_suggestion(suggestion_params, user) do
      {:ok, _suggestion} ->
        conn
        |> put_flash(:info, "Your suggestion has been submitted for review.")
        |> redirect(to: ~p"/suggestions/my")

      {:error, changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def my_suggestions(conn, _params) do
    user = Pow.Plug.current_user(conn)
    suggestions = Suggestions.list_user_suggestions(user)
    render(conn, :my_suggestions, suggestions: suggestions)
  end

  def index(conn, _params) do
    suggestions = Suggestions.list_pending_suggestions()
    render(conn, :index, suggestions: suggestions)
  end

  def show(conn, %{"id" => id}) do
    suggestion = Suggestions.get_suggestion!(id)
    render(conn, :show, suggestion: suggestion)
  end

  def approve(conn, %{"id" => id}) do
    suggestion = Suggestions.get_suggestion!(id)
    reviewer = Pow.Plug.current_user(conn)

    case Suggestions.approve_suggestion(suggestion, reviewer) do
      {:ok, {approved_suggestion, person}} ->
        ActivityLogs.log_suggestion_action(
          :approve_suggestion,
          approved_suggestion
        )

        ActivityLogs.log_person_action(
          :create_person_via_suggestion,
          person,
          approved_suggestion.user
        )

        conn
        |> put_flash(:info, "Suggestion approved and person added to database.")
        |> redirect(to: ~p"/people/#{person}")

      {:error, _} ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> redirect(to: ~p"/protected/suggestions/#{suggestion}")
    end
  end

  def reject(conn, %{"id" => id, "notes" => notes}) do
    suggestion = Suggestions.get_suggestion!(id)
    reviewer = Pow.Plug.current_user(conn)

    case Suggestions.reject_suggestion(suggestion, reviewer, notes) do
      {:ok, rejected_suggestion} ->
        ActivityLogs.log_suggestion_action(
          :reject_suggestion,
          rejected_suggestion
        )

        conn
        |> put_flash(:info, "Suggestion rejected.")
        |> redirect(to: ~p"/protected/suggestions")

      {:error, _} ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> redirect(to: ~p"/protected/suggestions/#{suggestion}")
    end
  end
end
