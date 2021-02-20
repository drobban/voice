defmodule Voice.Router do
  use Plug.Router
  require Logger

  plug(:match)
  plug(:dispatch)

  get "/" do
    Logger.debug("#{inspect(conn)}")

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(message()))
  end

  put "/voice_to" do
    # Perhaps make this async?
    case Notify.specific(conn.body_params) do
      {:ok, msg} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Poison.encode!(message(msg)))

      {:failure, msg} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Poison.encode!(message(msg)))
    end
  end

  put "/voice_at" do
    # make Async GenServer cast to :add_job
    # append job with GUID and send response.
    case GenServer.call(Notify.Alarm, {:add_job, conn.body_params}) do
      {:ok, jid} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(
          200,
          Poison.encode!(message("#{Base.url_encode64(jid, padding: false)} is active"))
        )

      {:failure, fail_msg} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(
          400,
          Poison.encode!(message("#{fail_msg}"))
        )
    end
  end

  delete "/:reference" do
    job_id = Base.url_decode64!(reference, padding: false)

    {status, _result} = GenServer.call(Notify.Alarm, {:remove_job, job_id})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(message("#{reference} removed - #{status}")))
  end

  match _ do
    send_resp(conn, 404, "Command not found")
  end

  defp message do
    %{
      response_type: "in_channel",
      text: "Hello from BOT :)"
    }
  end

  defp message(arg) do
    %{
      response_type: "in_channel",
      text: arg
    }
  end
end
