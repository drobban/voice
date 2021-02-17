defmodule Notify do
  require WebPushEncryption
  require Logger

  defp construct_sub(sub) do
    case sub do
      %{"endpoint" => endpoint, "keys" => %{"auth" => auth, "p256dh" => p256dh}} ->
        %{keys: %{auth: auth, p256dh: p256dh}, endpoint: endpoint}

      _default ->
        Logger.error("Sub missmatch / malformed")
        nil
    end
  end

  def specific(payload) do
    case payload do
      %{"subscription" => sub, "message" => msg, "vapid" => vapid} ->
        constructed_sub = construct_sub(sub)
        Logger.debug("#{inspect(Poison.encode!(msg))}")
        Logger.debug("#{inspect(constructed_sub)}")

        keys = %{:priv => vapid["private"], :pub => vapid["public"]}

        if !is_nil(constructed_sub) do
          WebPushEncryption.external_send_web_push(keys, Poison.encode!(msg), constructed_sub)
        end

      _default ->
        Logger.error("Malformed payload - Didnt match spec")
    end
  end
end
