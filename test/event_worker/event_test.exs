defmodule EventWorker.EventTest do
  use ExUnit.Case

  alias EventWorker.Event

  @invalid_attrs %{}
  @valid_attrs %{name: "event_name", status: "success", payload: %{}}

  test "changeset with valid attributes" do
    changeset = Event.changeset(%Event{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Event.changeset(%Event{}, @invalid_attrs)
    refute changeset.valid?
  end
end
