use Mix.Config

config :event_worker, EventWorker.Repo,
  database: "events_test",
  hostname: "localhost"
