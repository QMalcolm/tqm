defmodule TqmWeb.PersonSessionController do
  use TqmWeb, :controller

  alias Tqm.Accounts
  alias TqmWeb.PersonAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Account created successfully!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:person_return_to, ~p"/people/settings")
    |> create(params, "Password updated successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"person" => person_params}, info) do
    %{"email" => email, "password" => password} = person_params

    if person = Accounts.get_person_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, info)
      |> PersonAuth.log_in_person(person, person_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, "Invalid email or password")
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/people/log_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> PersonAuth.log_out_person()
  end
end
