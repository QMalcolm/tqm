defmodule TqmWeb.PersonConfirmationLiveTest do
  use TqmWeb.ConnCase

  import Phoenix.LiveViewTest
  import Tqm.AccountsFixtures

  alias Tqm.Accounts
  alias Tqm.Repo

  setup do
    %{person: person_fixture()}
  end

  describe "Confirm person" do
    test "renders confirmation page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/people/confirm/some-token")
      assert html =~ "Confirm Account"
    end

    test "confirms the given token once", %{conn: conn, person: person} do
      token =
        extract_person_token(fn url ->
          Accounts.deliver_person_confirmation_instructions(person, url)
        end)

      {:ok, lv, _html} = live(conn, ~p"/people/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "Person confirmed successfully"

      assert Accounts.get_person!(person.id).confirmed_at
      refute get_session(conn, :person_token)
      assert Repo.all(Accounts.PersonToken) == []

      # when not logged in
      {:ok, lv, _html} = live(conn, ~p"/people/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Person confirmation link is invalid or it has expired"

      # when logged in
      {:ok, lv, _html} =
        build_conn()
        |> log_in_person(person)
        |> live(~p"/people/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result
      refute Phoenix.Flash.get(conn.assigns.flash, :error)
    end

    test "does not confirm email with invalid token", %{conn: conn, person: person} do
      {:ok, lv, _html} = live(conn, ~p"/people/confirm/invalid-token")

      {:ok, conn} =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Person confirmation link is invalid or it has expired"

      refute Accounts.get_person!(person.id).confirmed_at
    end
  end
end
