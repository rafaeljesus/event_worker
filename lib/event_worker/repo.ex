defmodule EventWorker.Repo do
  use Ecto.Repo, otp_app: :event_worker, adapter: Mongo.Ecto
end
