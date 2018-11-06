defmodule Parkapp.ReservationsContext do
  @moduledoc """
  The Reservations context.
  """

  import Ecto.Query, warn: false
  alias Parkapp.Repo

  alias Parkapp.Reservations.ReservationType
  alias Parkapp.Logging

  @doc """
  Returns the list of reservation_types.

  ## Examples

      iex> list_reservation_types()
      [%ReservationType{}, ...]

  """
  def list_reservation_types do
    Repo.all(ReservationType)
  end

  @doc """
  Gets a single reservation_type.

  Raises `Ecto.NoResultsError` if the Reservation type does not exist.

  ## Examples

      iex> get_reservation_type!(123)
      %ReservationType{}

      iex> get_reservation_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_reservation_type!(id), do: Repo.get!(ReservationType, id)

  alias Parkapp.Reservations.ReservationStatus

  @doc """
  Returns the list of reservation_status.

  ## Examples

      iex> list_reservation_status()
      [%ReservationStatus{}, ...]

  """
  def list_reservation_status do
    Repo.all(ReservationStatus)
  end

  @doc """
  Gets a single reservation_status.

  Raises `Ecto.NoResultsError` if the Reservation status does not exist.

  ## Examples

      iex> get_reservation_status!(123)
      %ReservationStatus{}

      iex> get_reservation_status!(456)
      ** (Ecto.NoResultsError)

  """
  def get_reservation_status!(id), do: Repo.get!(ReservationStatus, id)

  alias Parkapp.Reservations.Reservation

  @doc """
  Returns the list of reservations.

  ## Examples

      iex> list_reservations()
      [%Reservation{}, ...]

  """
  def list_reservations do
    Repo.all(Reservation)
  end

  @doc """
  Returns the list of reservations ordered by updated_at.

  ## Examples

      iex> list_reservations_order_by_recent()
      [%Reservation{}, ...]

  """
  def list_reservations_order_by_recent do
    from(Reservation)
    |> order_by([r], desc: r.updated_at)
    |> Repo.all()
  end

  @doc """
  Returns the list of reservations ordered by inserted_at.

  ## Examples

      iex> list_reservations_order_by_inserted()
      [%Reservation{}, ...]

  """
  def list_reservations_order_by_inserted do
    from(Reservation)
    |> order_by([r], desc: r.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single reservation.

  Raises `Ecto.NoResultsError` if the Reservation does not exist.

  ## Examples

      iex> get_reservation!(123)
      %Reservation{}

      iex> get_reservation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_reservation!(id), do: Repo.get!(Reservation, id)

  @doc """
  Gets a single reservation.

  Returns nil if the Reservation does not exist.

  ## Examples

      iex> get_reservation(123)
      %Reservation{}

      iex> get_reservation(456)
      nil

  """
  def get_reservation(id), do: Repo.get(Reservation, id)

  @doc """
  Gets a single reservation with the given barcode

  Returns nil if the Reservation does not exist.

  ## Examples

      iex> get_reservation_by_barcode(123)
      %Reservation{}

      iex> get_reservation_by_barcode(456)
      nil

  """
  def get_reservation_by_barcode(barcode), do: Repo.get_by(Reservation, barcode: barcode)

  @doc """
  Gets a single reservation with the given locator

  Returns nil if the Reservation does not exist.

  ## Examples

      iex> get_reservation_by_locator(123)
      %Reservation{}

      iex> get_reservation_by_locator(456)
      nil

  """
  def get_reservation_by_locator(locator), do: Repo.get_by(Reservation, locator: locator)

  @doc """
  Gets the last reservation that was cancelled for the given device

  Returns nil if the Reservation does not exist.

  ## Examples

      iex> get_last_cancelled_reservation(123)
      %Reservation{}

      iex> get_last_cancelled_reservation(456)
      nil

  """
  def get_last_cancelled_reservation(device_id) do
    from(r in Reservation)
    |> where([r], r.device_id == ^device_id and r.cancelled == true)
    |> order_by([r], desc: r.cancelled_at)
    |> limit(1)
    |> Repo.one()
  end

  @doc """
  Creates a reservation.

  ## Examples

      iex> create_reservation(%{field: value})
      {:ok, %Reservation{}}

      iex> create_reservation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_reservation(attrs \\ %{}) do
    %Reservation{}
    |> Reservation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a reservation.

  ## Examples

      iex> update_reservation(reservation, %{field: new_value})
      {:ok, %Reservation{}}

      iex> update_reservation(reservation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_reservation(%Reservation{} = reservation, attrs) do
    reservation
    |> Reservation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a reservation using the in park changeset.

  ## Examples

      iex> update_reservation_inpark(reservation, %{field: new_value})
      {:ok, %Reservation{}}

      iex> update_reservation_inpark(reservation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_reservation_inpark(%Reservation{} = reservation, attrs) do
    reservation
    |> Reservation.inpark_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a reservation using the payment1 changeset.

  ## Examples

      iex> update_reservation_after_payment1(reservation, %{field: new_value})
      {:ok, %Reservation{}}

      iex> update_reservation_after_payment1(reservation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_reservation_after_payment1(%Reservation{} = reservation, attrs) do
    reservation
    |> Reservation.payment1_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a reservation using the payment2 changeset.

  ## Examples

      iex> update_reservation_after_payment2(reservation, %{field: new_value})
      {:ok, %Reservation{}}

      iex> update_reservation_after_payment2(reservation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_reservation_after_payment2(%Reservation{} = reservation, attrs) do
    reservation
    |> Reservation.payment2_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Reservation.

  ## Examples

      iex> delete_reservation(reservation)
      {:ok, %Reservation{}}

      iex> delete_reservation(reservation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_reservation(%Reservation{} = reservation) do
    Repo.delete(reservation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking reservation changes.

  ## Examples

      iex> change_reservation(reservation)
      %Ecto.Changeset{source: %Reservation{}}

  """
  def change_reservation(%Reservation{} = reservation) do
    Reservation.changeset(reservation, %{})
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking reservation changes.
  Uses the payment1_changeset.

  ## Examples

      iex> change_payment1_reservation(reservation)
      %Ecto.Changeset{source: %Reservation{}}

  """
  def change_payment_reservation(%Reservation{} = reservation, attrs \\ %{}) do
    Reservation.payment1_changeset(reservation, attrs)
  end

  alias Parkapp.Reservations.ReservationStatusHistory

  @doc """
  Returns the list of reservation_status_history.

  ## Examples

      iex> list_reservation_status_history()
      [%ReservationStatusHistory{}, ...]

  """
  def list_reservation_status_history do
    Repo.all(ReservationStatusHistory)
  end

  @doc """
  Gets a single reservation_status_history.

  Raises `Ecto.NoResultsError` if the Reservation status history does not exist.

  ## Examples

      iex> get_reservation_status_history!(123)
      %ReservationStatusHistory{}

      iex> get_reservation_status_history!(456)
      ** (Ecto.NoResultsError)

  """
  def get_reservation_status_history!(id), do: Repo.get!(ReservationStatusHistory, id)

  @doc """
  Creates a reservation_status_history.

  ## Examples

      iex> create_reservation_status_history(%{field: value})
      {:ok, %ReservationStatusHistory{}}

      iex> create_reservation_status_history(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_reservation_status_history(attrs \\ %{}) do
    %ReservationStatusHistory{}
    |> ReservationStatusHistory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a reservation_status_history.
  """
  def create_reservation_status_history(reservation_id, previous_status, next_status) do
    create_reservation_status_history(%{
      transitioned_at: DateTime.utc_now(),
      reservation_id: reservation_id,
      previous_reservation_status_id: previous_status,
      next_reservation_status_id: next_status,
      active: true
    })
  end

  @doc """
  Updates a reservation_status_history.

  ## Examples

      iex> update_reservation_status_history(reservation_status_history, %{field: new_value})
      {:ok, %ReservationStatusHistory{}}

      iex> update_reservation_status_history(reservation_status_history, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_reservation_status_history(
        %ReservationStatusHistory{} = reservation_status_history,
        attrs
      ) do
    reservation_status_history
    |> ReservationStatusHistory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ReservationStatusHistory.

  ## Examples

      iex> delete_reservation_status_history(reservation_status_history)
      {:ok, %ReservationStatusHistory{}}

      iex> delete_reservation_status_history(reservation_status_history)
      {:error, %Ecto.Changeset{}}

  """
  def delete_reservation_status_history(%ReservationStatusHistory{} = reservation_status_history) do
    Repo.delete(reservation_status_history)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking reservation_status_history changes.

  ## Examples

      iex> change_reservation_status_history(reservation_status_history)
      %Ecto.Changeset{source: %ReservationStatusHistory{}}

  """
  def change_reservation_status_history(%ReservationStatusHistory{} = reservation_status_history) do
    ReservationStatusHistory.changeset(reservation_status_history, %{})
  end

  # API

  @doc """
    Retrieves from the database the active history for the given reservation
  """
  @spec get_active_reservation_history(Integer) :: ReservationStatusHistory | nil
  def get_active_reservation_history(reservation_id) do
    Repo.get_by(ReservationStatusHistory, active: true, reservation_id: reservation_id)
  end

  @doc """
    Retrives the current reservation for the given device.
    It makes sure the status history is correct and ignores the closed reservations
  """
  @spec get_current_reservation(Integer) :: Reservation | nil
  def get_current_reservation(device_id) do
    from(r in Reservation)
    |> join(
      :inner,
      [r],
      history in ReservationStatusHistory,
      r.id == history.reservation_id and history.active == true
    )
    |> where(
      [r, history],
      r.device_id == ^device_id and r.reservation_status_id != ^ReservationStatus.Enum.closed()
    )
    |> Repo.one()
  end

  @doc """
  Gets the active history for the given reservation and deactivates it.
  """
  @spec deactivate_reservation_status_history(Integer) ::
          {:ok, ReservationStatusHistory} | {:error, Changeset} | nil
  def deactivate_reservation_status_history(reservation_id) do
    with(
      last_history <- get_active_reservation_history(reservation_id),
      false <- is_nil(last_history),
      {:ok, inactive_history} <-
        update_reservation_status_history(last_history, %{
          active: false
        })
    ) do
      {:ok, inactive_history}
    else
      {:error, changeset} ->
        {:error, changeset}

      _error ->
        nil
    end
  end

  @doc """
    Deletes every reservation and respective history
  """
  @spec delete_all_reservations() :: :ok
  def delete_all_reservations() do
    Repo.transaction(fn ->
      list_reservation_status_history()
      |> Enum.each(fn status_history ->
        delete_reservation_status_history(status_history)
      end)

      Logging.list_external_payment_logs()
      |> Enum.each(fn external_payment_log ->
        Logging.delete_external_payment_log(external_payment_log)
      end)

      list_reservations()
      |> Enum.each(fn reservation ->
        delete_reservation(reservation)
      end)
    end)

    :ok
  end

  @doc """
    Creates a reservation with the given attributes in the open state.
    Creates the first entry in the status history.
  """
  @spec create_reservation_initial_state(Map) :: {:ok, Reservation} | {:error, Changeset} | nil
  def create_reservation_initial_state(attrs) when is_map(attrs) do
    Repo.transaction(fn ->
      with(
        open_status <- ReservationStatus.Enum.open(),
        attrs <- Map.put(attrs, :reservation_status_id, open_status),
        {:ok, reservation} <- create_reservation(attrs),
        {:ok, _reservation_status_history} <-
          create_reservation_status_history(reservation.id, nil, open_status)
      ) do
        {:ok, reservation}
      else
        {:error, changeset} ->
          Repo.rollback({:error, changeset})

        _error ->
          Repo.rollback(nil)
      end
    end)
    |> elem(1)
  end

  @doc """
    Updates the reservation to the in park state.
    Creates the second entry in the status history. Deactivates the previous one.
  """
  @spec move_to_in_park_state(Reservation, DateTime) ::
          {:ok, Reservation} | {:error, Changeset} | nil
  def move_to_in_park_state(%Reservation{} = reservation, parking_start_time) do
    open_status = ReservationStatus.Enum.open()
    in_park_status = ReservationStatus.Enum.in_park()

    Repo.transaction(fn ->
      with(
        {:ok, reservation} <-
          update_reservation_inpark(reservation, %{
            parking_start_time: parking_start_time
          }),
        {:ok, reservation} <- move_reservation_from_to(reservation, open_status, in_park_status)
      ) do
        {:ok, reservation}
      else
        {:error, changeset} ->
          Repo.rollback({:error, changeset})

        _error ->
          Repo.rollback(nil)
      end
    end)
    |> elem(1)
  end

  @doc """
    Updates the reservation to the external payment state. Sets the context_token and amount if successful.
    Creates the third entry in the status history. Deactivates the previous one.
  """
  @spec move_to_external_payment_state(Reservation) ::
          {:ok, Reservation} | {:error, Changeset} | nil
  def move_to_external_payment_state(%Reservation{} = reservation) do
    in_park_status = ReservationStatus.Enum.in_park()
    external_payment_status = ReservationStatus.Enum.external_payment()

    Repo.transaction(fn ->
      with(
        {:ok, reservation} <-
          move_reservation_from_to(reservation, in_park_status, external_payment_status)
      ) do
        {:ok, reservation}
      else
        {:error, changeset} ->
          Repo.rollback({:error, changeset})

        _error ->
          Repo.rollback(nil)
      end
    end)
    |> elem(1)
  end

  @doc """
    Updates the reservation to the payment2 state.
    Creates the fifth entry in the status history. Deactivates the previous one.
  """
  @spec move_to_payment2_state(Reservation, DateTime) ::
          {:ok, Reservation} | {:error, Changeset} | nil
  def move_to_payment2_state(%Reservation{} = reservation, parking_payment_time) do
    external_payment_status = ReservationStatus.Enum.external_payment()
    payment2_status = ReservationStatus.Enum.payment2()

    Repo.transaction(fn ->
      with(
        {:ok, reservation} <-
          update_reservation_after_payment2(reservation, %{
            parking_payment_time: parking_payment_time
          }),
        {:ok, reservation} <-
          move_reservation_from_to(reservation, external_payment_status, payment2_status)
      ) do
        {:ok, reservation}
      else
        {:error, changeset} ->
          Repo.rollback({:error, changeset})

        _error ->
          Repo.rollback(nil)
      end
    end)
    |> elem(1)
  end

  @doc """
    Updates the reservation to the closed state.
    Creates the sixth and final entry in the status history. Deactivates the previous one.
  """
  @spec move_to_closed_state(Reservation) :: {:ok, Reservation} | {:error, Changeset} | nil
  def move_to_closed_state(%Reservation{} = reservation) do
    payment2_status = ReservationStatus.Enum.payment2()
    closed_status = ReservationStatus.Enum.closed()

    move_reservation_from_to(reservation, payment2_status, closed_status)
  end

  @spec close_reservation(Reservation) :: {:ok, Reservation} | {:error, Changeset} | nil
  def close_reservation(%Reservation{} = reservation) do
    closed_status = ReservationStatus.Enum.closed()

    move_reservation_from_to(reservation, reservation.reservation_status_id, closed_status)
  end

  @spec cancel_reservation(Reservation) :: {:ok, Reservation} | {:error, Changeset} | nil
  def cancel_reservation(%Reservation{} = reservation) do
    Repo.transaction(fn ->
      with(
        {:ok, reservation} <-
          update_reservation(reservation, %{
            cancelled: true,
            cancelled_at: DateTime.utc_now()
          }),
        {:ok, reservation} <- close_reservation(reservation)
      ) do
        {:ok, reservation}
      else
        {:error, changeset} ->
          Repo.rollback({:error, changeset})

        _else ->
          Repo.rollback(nil)
      end
    end)
    |> elem(1)
  end

  @doc """
    Abstract function that knows tghe steps involved into changing a reservation status.
  """
  @spec move_reservation_from_to(Reservation, Integer, Integer) ::
          {:ok, Reservation} | {:error, Changeset} | nil
  def move_reservation_from_to(%Reservation{} = reservation, previous_status, next_status)
      when is_integer(previous_status) and is_integer(next_status) do
    Repo.transaction(fn ->
      with(
        true <- previous_status != next_status,
        true <- reservation.reservation_status_id == previous_status,
        {:ok, reservation} <-
          update_reservation(reservation, %{
            reservation_status_id: next_status
          }),
        {:ok, _inactive_history} <- deactivate_reservation_status_history(reservation.id),
        {:ok, _reservation_status_history} <-
          create_reservation_status_history(reservation.id, previous_status, next_status)
      ) do
        {:ok, reservation}
      else
        {:error, changeset} ->
          Repo.rollback({:error, changeset})

        _error ->
          Repo.rollback(nil)
      end
    end)
    |> elem(1)
  end

  @doc """
  Sets the values changed by the inpark back to nil
  """
  @spec revert_in_park_values(Reservation) :: {:ok, Reservation} | {:error, Changeset}
  def revert_in_park_values(%Reservation{} = reservation) do
    Reservation.revert_inpark_changeset(reservation, %{})
    |> Repo.update()
  end

  @doc """
    Sets the values changed by the payment1 route back to nil
  """
  @spec revert_payment1_values(Reservation) :: {:ok, Reservation} | {:error, Changeset}
  def revert_payment1_values(%Reservation{} = reservation) do
    Reservation.revert_payment1_changeset(reservation, %{})
    |> Repo.update()
  end

  @doc """
    Sets the values changed by the payment1 route back to nil
  """
  @spec revert_payment2_values(Reservation) :: {:ok, Reservation} | {:error, Changeset}
  def revert_payment2_values(%Reservation{} = reservation) do
    Reservation.revert_payment2_changeset(reservation, %{})
    |> Repo.update()
  end

  @doc """
    Reverts the to the inpark state when the MVWay webhook informs that the payment was not successfull
  """
  @spec revert_from_external_payment_to_in_park(Reservation) ::
          {:ok, Reservation} | {:error, Changeset} | nil
  def revert_from_external_payment_to_in_park(%Reservation{} = reservation) do
    Repo.transaction(fn ->
      with(
        {:ok, reservation} <- revert_payment1_values(reservation),
        {:ok, reservation} <-
          move_reservation_from_to(
            reservation,
            ReservationStatus.Enum.external_payment(),
            ReservationStatus.Enum.in_park()
          )
      ) do
        {:ok, reservation}
      else
        {:error, changeset} ->
          Repo.rollback({:error, changeset})

        _else ->
          Repo.rollback(nil)
      end
    end)
    |> elem(1)
  end
end
