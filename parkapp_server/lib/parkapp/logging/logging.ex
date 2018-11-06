defmodule Parkapp.Logging do
  @moduledoc """
  The Logging context.
  """

  import Ecto.Query, warn: false
  alias Parkapp.Repo

  alias Parkapp.Logging.ExternalPaymentLog

  @doc """
  Returns the list of external_payment_logs.

  ## Examples

      iex> list_external_payment_logs()
      [%ExternalPaymentLog{}, ...]

  """
  def list_external_payment_logs do
    Repo.all(ExternalPaymentLog)
  end

  @doc """
  Returns the list of external_payment_logs for the given reservation_id.

  ## Examples

      iex> list_external_payment_logs(reservation_id)
      [%ExternalPaymentLog{}, ...]

  """
  def list_external_payment_logs(reservation_id) do
    from(epl in ExternalPaymentLog)
    |> where([epl], epl.reservation_id == ^reservation_id)
    |> Repo.all()
  end

  @doc """
  Gets a single external_payment_log.

  Raises `Ecto.NoResultsError` if the External payment log does not exist.

  ## Examples

      iex> get_external_payment_log!(123)
      %ExternalPaymentLog{}

      iex> get_external_payment_log!(456)
      ** (Ecto.NoResultsError)

  """
  def get_external_payment_log!(id), do: Repo.get!(ExternalPaymentLog, id)

  @doc """
  Creates a external_payment_log.

  ## Examples

      iex> create_external_payment_log(%{field: value})
      {:ok, %ExternalPaymentLog{}}

      iex> create_external_payment_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_external_payment_log(attrs \\ %{}) do
    %ExternalPaymentLog{}
    |> ExternalPaymentLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a external_payment_log.

  ## Examples

      iex> update_external_payment_log(external_payment_log, %{field: new_value})
      {:ok, %ExternalPaymentLog{}}

      iex> update_external_payment_log(external_payment_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_external_payment_log(%ExternalPaymentLog{} = external_payment_log, attrs) do
    external_payment_log
    |> ExternalPaymentLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ExternalPaymentLog.

  ## Examples

      iex> delete_external_payment_log(external_payment_log)
      {:ok, %ExternalPaymentLog{}}

      iex> delete_external_payment_log(external_payment_log)
      {:error, %Ecto.Changeset{}}

  """
  def delete_external_payment_log(%ExternalPaymentLog{} = external_payment_log) do
    Repo.delete(external_payment_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking external_payment_log changes.

  ## Examples

      iex> change_external_payment_log(external_payment_log)
      %Ecto.Changeset{source: %ExternalPaymentLog{}}

  """
  def change_external_payment_log(%ExternalPaymentLog{} = external_payment_log) do
    ExternalPaymentLog.changeset(external_payment_log, %{})
  end
end
