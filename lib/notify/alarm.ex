defmodule Notify.Alarm.State do
  defstruct current_jobs: %{}
end

defmodule Notify.Alarm do
  use GenServer
  require Logger

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  # Use of cast is async.
  @impl true
  def handle_call({:add_job, payload}, _from, state) do
    case payload do
      %{"alarm" => alarm, "data" => data} ->
        {:ok, requested_time, _} = DateTime.from_iso8601(alarm)
        time_delta = DateTime.diff(requested_time, DateTime.utc_now(), :millisecond)
        id = "#{inspect(make_ref())}"
        timer = Process.send_after(self(), {:run_job, id}, max(0, time_delta))

        new_state = %{
          state
          | current_jobs: Map.put(state.current_jobs, id, %{:timer => timer, :data => data})
        }

        {:reply, {:ok, id}, new_state}

      default ->
        Logger.debug("#{inspect(default)}")
        {:reply, {:failure, "missing keys"}, state}
    end
  end

  @impl true
  def handle_call({:remove_job, id}, _from, state) do
    result = Process.cancel_timer(state.current_jobs[id][:timer])
    new_state = %{state | current_jobs: Map.delete(state.current_jobs, id)}

    if result do
      {:reply, {:ok, result}, new_state}
    else
      {:reply, {:failure, result}, new_state}
    end
  end

  def handle_call({:get_jobs}, _from, state) do
    job_ids = Map.keys(state.current_jobs)
    b64_ids = Enum.map(job_ids, &Base.url_encode64(&1, padding: false))
    {:reply, {:ok, b64_ids}, state}
  end

  @impl true
  def handle_info({:run_job, id}, state) do
    Logger.debug("Sending message")
    Logger.debug("#{inspect(state.current_jobs[id])}")
    data = state.current_jobs[id][:data]

    cond do
      data ->
        Notify.specific(data)

      !data ->
        Logger.warning("Missing :data in state at #{id}")
    end

    new_state = %{state | current_jobs: Map.delete(state.current_jobs, id)}
    {:noreply, new_state}
  end
end
