defmodule VoiceTest do
  use ExUnit.Case
  doctest Voice

  test "greets the world" do
    assert Voice.hello() == :world
  end
end
