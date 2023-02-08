defmodule Tqm.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Tqm.Accounts` context.
  """

  def unique_person_email, do: "person#{System.unique_integer()}@example.com"
  def valid_person_password, do: "hello world!"

  def valid_person_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_person_email(),
      password: valid_person_password()
    })
  end

  def person_fixture(attrs \\ %{}) do
    {:ok, person} =
      attrs
      |> valid_person_attributes()
      |> Tqm.Accounts.register_person()

    person
  end

  def owner_person_fixture() do
    {:ok, owner} =
      person_fixture(%{
        email: "owner@example.com",
        password: "badexamplepassword"
      })
      |> Tqm.Accounts.change_person_role(%{role: :owner})
      |> Tqm.Repo.update()

    owner
  end

  def non_stranger_person_fixture() do
    {:ok, non_stranger} =
      person_fixture(%{
        email: "non_stranger@example.com",
        password: "badexamplepassword"
      })
      |> Tqm.Accounts.change_person_role(%{role: :non_stranger})
      |> Tqm.Repo.update()

    non_stranger
  end

  def stranger_person_fixture() do
    {:ok, stranger} =
      person_fixture(%{
        email: "stranger@example.com",
        password: "badexamplepassword"
      })
      |> Tqm.Accounts.change_person_role(%{role: :stranger})
      |> Tqm.Repo.update()

    stranger
  end

  def extract_person_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
