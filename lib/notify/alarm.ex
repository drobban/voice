defmodule Voice.Alarm.State do
  defstruct current_jobs: %{}
end

defmodule Voice.Alarm do
  use GenServer
  require Logger

  @impl true
  def init(state) do
    {:ok, state}
  end

  # Use of cast is async.
  @impl true
  def handle_cast({:add_job, payload}, state) do
    Logger.debug("#{inspect(payload)} - #{inspect(state)}")
    fake_id = 1010
    new_state = %{state | current_jobs: Map.put(state.current_jobs, fake_id, :active)}
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:remove_job, id}, state) do
    Logger.debug("#{inspect(id)} - #{inspect(state)}")
    fake_id = id
    new_state = %{state | current_jobs: Map.delete(state.current_jobs, id)}
    {:noreply, new_state}
  end
end
