defmodule EventWorker.Consumer do

  alias EventWorker.{Event, Repo}

  def consume(channel, tag, redelivered, payload) do
    changeset = Event.changeset(%Event{}, payload)
    case Repo.insert!(changeset) do
      {:ok, event} -> Basic.ack channel, tag
      {:error, _changeset} -> Basic.reject channel, tag, requeue: not redelivered
    end
  end
end
