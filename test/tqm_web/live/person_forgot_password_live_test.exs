defmodule TqmWeb.PersonForgotPasswordLiveTest do
  use TqmWeb.ConnCase

  import Phoenix.LiveViewTest
  import Tqm.AccountsFixtures

  alias Tqm.Accounts
  alias Tqm.Repo

  describe "Forgot password page" do
    test "renders email page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/people/reset_password")

      assert html =~ "Forgot your password?"
      assert html =~ "Register</a>"
      assert html =~ "Log in</a>"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_person(person_fixture())
        |> live(~p"/people/reset_password")
        |> follow_redirect(conn, ~p"/")

      assert {:ok, _conn} = result
    end
  end

  describe "Reset link" do
    setup do
      %{person: person_fixture()}
    end

    test "sends a new reset password token", %{conn: conn, person: person} do
      {:ok, lv, _html} = live(conn, ~p"/people/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", person: %{"email" => person.email})
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your email is in our system"

      assert Repo.get_by!(Accounts.PersonToken, person_id: person.id).context ==
               "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/people/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", person: %{"email" => "unknown@example.com"})
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your email is in our system"
      assert Repo.all(Accounts.PersonToken) == []
    end
  end
end
