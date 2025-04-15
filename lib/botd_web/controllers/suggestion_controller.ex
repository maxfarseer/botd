defmodule BotdWeb.SuggestionController do
  use BotdWeb, :controller
  alias Botd.Suggestions
  alias Botd.Suggestions.Suggestion

  # Für Members - Neue Vorschläge
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

  # Für Members - Meine Vorschläge anzeigen
  def my_suggestions(conn, _params) do
    user = Pow.Plug.current_user(conn)
    suggestions = Suggestions.list_user_suggestions(user)
    render(conn, :my_suggestions, suggestions: suggestions)
  end

  # Für Moderatoren - Vorschläge prüfen
  def index(conn, _params) do
    suggestions = Suggestions.list_pending_suggestions()
    render(conn, :index, suggestions: suggestions)
  end

  def show(conn, %{"id" => id}) do
    suggestion = Suggestions.get_suggestion!(id)
    render(conn, :show, suggestion: suggestion)
  end

  # Für Moderatoren - Vorschläge genehmigen
  def approve(conn, %{"id" => id}) do
    suggestion = Suggestions.get_suggestion!(id)
    reviewer = Pow.Plug.current_user(conn)

    case Suggestions.approve_suggestion(suggestion, reviewer) do
      {:ok, {_suggestion, person}} ->
        conn
        |> put_flash(:info, "Suggestion approved and person added to database.")
        |> redirect(to: ~p"/people/#{person}")

      {:error, _} ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> redirect(to: ~p"/suggestions/#{suggestion}")
    end
  end

  # Für Moderatoren - Vorschläge ablehnen
  def reject(conn, %{"id" => id, "suggestion" => %{"notes" => notes}}) do
    suggestion = Suggestions.get_suggestion!(id)
    reviewer = Pow.Plug.current_user(conn)

    case Suggestions.reject_suggestion(suggestion, reviewer, notes) do
      {:ok, _suggestion} ->
        conn
        |> put_flash(:info, "Suggestion rejected.")
        |> redirect(to: ~p"/suggestions")

      {:error, _} ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> redirect(to: ~p"/suggestions/#{suggestion}")
    end
  end
end
