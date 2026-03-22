defmodule BotdWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use BotdWeb, :html

  import BotdWeb.Helpers

  @git_sha System.cmd("git", ["rev-parse", "--short", "HEAD"]) |> elem(0) |> String.trim()
  @git_date System.cmd("git", ["log", "-1", "--format=%cd", "--date=format:%Y-%m-%d %H:%M"])
            |> elem(0)
            |> String.trim()

  def git_sha, do: @git_sha
  def git_date, do: @git_date

  embed_templates "page_html/*"
end
