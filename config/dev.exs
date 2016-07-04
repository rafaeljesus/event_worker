use Mix.Config

config :event_worker, EventWorker.Repo,
  database: "events_dev",
  hostname: "localhost"
