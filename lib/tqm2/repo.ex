defmodule Tqm2.Repo do
  use Ecto.Repo,
    otp_app: :tqm2,
    adapter: Ecto.Adapters.Postgres
end
