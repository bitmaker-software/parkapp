defmodule ParkappWeb.ApiIntegration.MBWay.WebhookData do
  @moduledoc """
    Struct that formalizes the information used for completing a payment
  """

  require Logger

  defstruct result_code: "", device_id: "", body: ""

  @possible_successfull_result_codes [
    "000.000.000",
    "000.000.100",
    "000.100.110",
    "000.100.111",
    "000.100.112",
    "000.600.000"
  ]

  @indifferent_result_codes [
    "800.400.500"
  ]

  @doc """
    Checks if the result code received by the webhook means the payment was successfull
  """
  @spec validate(WebhookData) :: Boolean
  def validate(%__MODULE__{result_code: result_code}) do
    result_code in @possible_successfull_result_codes
  end

  @doc """
    Checks if the result code received by the webhook means the reservation should revert to inpark
  """
  @spec should_revert(WebhookData) :: Boolean
  def should_revert(%__MODULE__{result_code: result_code}) do
    result_code not in @indifferent_result_codes
  end

  @doc """
    Builds the MODULE struct given the decoded body
  """
  @spec build(Map) :: WebhookData | nil
  def build(body) when is_map(body) do
    Logger.info(Poison.encode!(body))

    with(
      true <- is_body_valid(body),
      Logger.info("body is valid"),
      payload <- Map.get(body, "payload", %{}),
      device_id <-
        Map.get(payload, "customParameters", %{})
        |> Map.get("device_id"),
      Logger.info(device_id),
      code <- Map.get(payload, "result", %{}) |> Map.get("code"),
      Logger.info(code)
    ) do
      %__MODULE__{result_code: code, device_id: device_id, body: Poison.encode!(body)}
    else
      _ ->
        nil
    end
  end

  defp is_body_valid(body) do
    with(
      true <- Map.get(body, "type", "") == "PAYMENT",
      true <- Map.has_key?(body, "payload"),
      payload <- Map.get(body, "payload", %{}),
      true <-
        [
          "id",
          "amount",
          "currency",
          "result",
          "customParameters",
          "ndc",
          "merchantTransactionId",
          "virtualAccount"
        ]
        |> Enum.reduce(true, fn key, acc ->
          cond do
            key in Map.keys(payload) ->
              acc

            true ->
              false
          end
        end),
      true <- Map.get(payload, "customParameters", %{}) |> Map.has_key?("device_id"),
      true <- Map.get(payload, "result", %{}) |> Map.has_key?("code")
    ) do
      true
    else
      _ ->
        false
    end
  end
end
