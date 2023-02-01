defmodule Tqm.Repo do
  use Ecto.Repo,
    otp_app: :tqm,
    adapter: Ecto.Adapters.Postgres
end
