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
    Notify.specific(conn.body_params)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(message("PUT request made")))
  end

  put "/voice_at" do
    # make Async GenServer cast to :add_job
    # append job with GUID and send response.
    {:ok, jid} = GenServer.call(Notify.Alarm, {:add_job, conn.body_params})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(
      200,
      Poison.encode!(message("#{Base.url_encode64(jid, padding: false)} is active"))
    )
  end

  delete "/:reference" do
    job_id = Base.url_decode64!(reference, padding: false)

    {status, result} = GenServer.call(Notify.Alarm, {:remove_job, job_id})

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
