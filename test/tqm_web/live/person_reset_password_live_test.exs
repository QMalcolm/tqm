defmodule TqmWeb.PersonResetPasswordLiveTest do
  use TqmWeb.ConnCase

  import Phoenix.LiveViewTest
  import Tqm.AccountsFixtures

  alias Tqm.Accounts

  setup do
    person = person_fixture()

    token =
      extract_person_token(fn url ->
        Accounts.deliver_person_reset_password_instructions(person, url)
      end)

    %{token: token, person: person}
  end

  describe "Reset password page" do
    test "renders reset password with valid token", %{conn: conn, token: token} do
      {:ok, _lv, html} = live(conn, ~p"/people/reset_password/#{token}")

      assert html =~ "Reset Password"
    end

    test "does not render reset password with invalid token", %{conn: conn} do
      {:error, {:redirect, to}} = live(conn, ~p"/people/reset_password/invalid")

      assert to == %{
               flash: %{"error" => "Reset password link is invalid or it has expired."},
               to: ~p"/"
             }
    end

    test "renders errors for invalid data", %{conn: conn, token: token} do
      {:ok, lv, _html} = live(conn, ~p"/people/reset_password/#{token}")

      result =
        lv
        |> element("#reset_password_form")
        |> render_change(
          person: %{"password" => "secret12", "confirmation_password" => "secret123456"}
        )

      assert result =~ "should be at least 12 character"
      assert result =~ "does not match password"
    end
  end

  describe "Reset Password" do
    test "resets password once", %{conn: conn, token: token, person: person} do
      {:ok, lv, _html} = live(conn, ~p"/people/reset_password/#{token}")

      {:ok, conn} =
        lv
        |> form("#reset_password_form",
          person: %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        )
        |> render_submit()
        |> follow_redirect(conn, ~p"/people/log_in")

      refute get_session(conn, :person_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Password reset successfully"
      assert Accounts.get_person_by_email_and_password(person.email, "new valid password")
    end

    test "does not reset password on invalid data", %{conn: conn, token: token} do
      {:ok, lv, _html} = live(conn, ~p"/people/reset_password/#{token}")

      result =
        lv
        |> form("#reset_password_form",
          person: %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        )
        |> render_submit()

      assert result =~ "Reset Password"
      assert result =~ "should be at least 12 character(s)"
      assert result =~ "does not match password"
    end
  end

  describe "Reset password navigation" do
    test "redirects to login page when the Log in button is clicked", %{conn: conn, token: token} do
      {:ok, lv, _html} = live(conn, ~p"/people/reset_password/#{token}")

      {:ok, conn} =
        lv
        |> element(~s|main a[href="/people/log_in"]|)
        |> render_click()
        |> follow_redirect(conn, ~p"/people/log_in")

      assert conn.resp_body =~ "Sign in"
    end

    test "redirects to password reset page when the Register button is clicked", %{
      conn: conn,
      token: token
    } do
      {:ok, lv, _html} = live(conn, ~p"/people/reset_password/#{token}")

      {:ok, conn} =
        lv
        |> element(~s|main a[href="/people/register"]|)
        |> render_click()
        |> follow_redirect(conn, ~p"/people/register")

      assert conn.resp_body =~ "Register"
    end
  end
end
