defmodule Noveo.Repo do
  use Ecto.Repo,
    otp_app: :noveo,
    adapter: Ecto.Adapters.Postgres
end
