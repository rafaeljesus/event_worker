defmodule EventWorker.Handler do

  alias EventWorker.{Event, Repo}

  def handle_message(payload) do
    with changeset <- Event.changeset(%Event{}, payload),
      {:ok, event} <- Repo.insert!(changeset),
      do: {:ok, event}
  end
end
