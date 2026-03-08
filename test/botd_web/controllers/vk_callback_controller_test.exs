defmodule BotdWeb.VKCallbackControllerTest do
  use BotdWeb.ConnCase, async: true

  describe "handle/2 — confirmation" do
    test "responds with the VK confirmation string", %{conn: conn} do
      System.put_env("VK_CONFIRMATION_STRING", "abc123confirm")

      conn = post(conn, ~p"/vk/callback", %{"type" => "confirmation"})

      assert response(conn, 200) == "abc123confirm"
    after
      System.delete_env("VK_CONFIRMATION_STRING")
    end

    test "responds with empty string when VK_CONFIRMATION_STRING is not set", %{conn: conn} do
      System.delete_env("VK_CONFIRMATION_STRING")

      conn = post(conn, ~p"/vk/callback", %{"type" => "confirmation"})

      assert response(conn, 200) == ""
    end
  end

  describe "handle/2 — events" do
    test "responds with ok for wall_post_new events", %{conn: conn} do
      conn =
        post(conn, ~p"/vk/callback", %{
          "type" => "wall_post_new",
          "object" => %{"id" => 1, "post_type" => "post", "text" => "hello", "owner_id" => -1}
        })

      assert response(conn, 200) == "ok"
    end

    test "responds with ok for unknown event types", %{conn: conn} do
      conn = post(conn, ~p"/vk/callback", %{"type" => "group_join", "object" => %{}})

      assert response(conn, 200) == "ok"
    end
  end

  describe "handle/2 — secret key validation" do
    test "accepts request when secret matches VK_SECRET_KEY", %{conn: conn} do
      System.put_env("VK_SECRET_KEY", "mysecret")

      conn =
        post(conn, ~p"/vk/callback", %{
          "type" => "group_join",
          "object" => %{},
          "secret" => "mysecret"
        })

      assert response(conn, 200) == "ok"
    after
      System.delete_env("VK_SECRET_KEY")
    end

    test "still responds ok when secret is wrong (does not crash)", %{conn: conn} do
      System.put_env("VK_SECRET_KEY", "mysecret")

      conn =
        post(conn, ~p"/vk/callback", %{
          "type" => "group_join",
          "object" => %{},
          "secret" => "wrongsecret"
        })

      assert response(conn, 200) == "ok"
    after
      System.delete_env("VK_SECRET_KEY")
    end

    test "accepts request when VK_SECRET_KEY is not configured", %{conn: conn} do
      System.delete_env("VK_SECRET_KEY")

      conn = post(conn, ~p"/vk/callback", %{"type" => "group_join", "object" => %{}})

      assert response(conn, 200) == "ok"
    end
  end
end
