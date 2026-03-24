defmodule BotdWeb.DesignSystemControllerTest do
  use BotdWeb.ConnCase, async: true

  describe "GET /design-system" do
    test "renders the design system page", %{conn: conn} do
      conn = get(conn, ~p"/design-system")
      assert html_response(conn, 200) =~ "Spectral Archive"
    end

    test "renders all component sections", %{conn: conn} do
      conn = get(conn, ~p"/design-system")
      html = html_response(conn, 200)

      assert html =~ "Back Link"
      assert html =~ "Buttons"
      assert html =~ "Cards & Surfaces"
      assert html =~ "Colors"
      assert html =~ "Effects"
      assert html =~ "Flash"
      assert html =~ "Header"
      assert html =~ "Icons (Heroicons)"
      assert html =~ "Inputs"
      assert html =~ "List"
      assert html =~ "Modal"
      assert html =~ "Pagination"
      assert html =~ "Person Card"
      assert html =~ "Shadows"
      assert html =~ "Table"
      assert html =~ "Typography"
    end
  end
end
