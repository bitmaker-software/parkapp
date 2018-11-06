defmodule ParkappWeb.ApiIntegration.Embers.API do
  @moduledoc """
    Main implementation of the Embers API.
  """

  @behaviour ParkappWeb.ApiIntegration.Embers.Behaviour

  import ParkappWeb.ApiIntegration.Embers.Helpers

  alias Parkapp.Reservations.ReservationType.ConfigurationStruct

  @doc """
    Uses the Embers's Routing API to calculate the route between from and to geo_points
  """
  def get_route(from, to, mode) do
    {domain, api_key, max_walk_distance, timezone} = get_config(:routing)
    {date, time} = now_date_time_tuple_with_format(timezone)

    url =
      "#{domain}/routing/?fromPlace=#{from}&toPlace=#{to}&mode=#{mode}&maxWalkDistance=#{
        max_walk_distance
      }&date=#{date}&time=#{time}"

    get(url, api_key)
    |> handle_http_response()
  end

  # https://api.embers.city/offstreet-parking/parking-areas/85/
  # https://api.embers.city/offstreet-parking/occupancy-reports/?ordering=timestamp&parking_area=85&timestamp__gte=2018-09-19T09%3A03%3A19.616240Z
  # {
  #   "id": 85,
  #   "sources": [
  #     {
  #       "id": 2,
  #       "name": "Porto parking data (TEST)",
  #       "location_name": "Porto",
  #       "type": "parking",
  #       "organization": 10
  #     }
  #   ],
  #   "occupied_spots": 51,
  #   "free_spots": 449,
  #   "free_spots_display": null,
  #   "assets": [],
  #   "name": "1",
  #   "location": {
  #     "type": "Point",
  #     "coordinates": [
  #       -8.609497,
  #       41.150922
  #     ]
  #   },
  #   "total_capacity": 500,
  #   "spots_margin": 0,
  #   "reserved_spots": 0,
  #   "management_type": "w",
  #   "webservice_url": null,
  #   "display_name": "Rotación",
  #   "external_id": "1",
  #   "description": "Rotación",
  #   "city": "Porto",
  #   "vehicle_type": "c",
  #   "charge_type": null,
  #   "additional_fields": null,
  #   "is_emulated": false,
  #   "copying_from": null
  # }

  @doc """
    Uses the Embers's API to get updated information of the given reservation
  """
  def get_reservation(locator) do
    {domain, api_key, _timezone, _} = get_config(:trindade_park)

    url = "#{domain}/porto-parking/reservations/?locator=#{locator}"

    get(url, api_key)
    |> handle_http_response()
  end

  @doc """
    Creates a new reservation by posting Embers's API
  """
  def make_reservation(%ConfigurationStruct{} = config) do
    {domain, api_key, timezone, parking_time} = get_config(:trindade_park)

    url = "#{domain}/porto-parking/reservations"

    activation =
      Timex.now(timezone)
      |> Timex.add(Timex.Duration.from_minutes(config.delay_activation))

    post(url, api_key, %{
      activation: format_date_time(activation),
      expiry:
        activation
        |> Timex.add(Timex.Duration.from_minutes(parking_time))
        |> format_date_time(),
      product_type: config.product_type
    })
    |> handle_http_response()
  end

  # {
  #   "product_type": "1",
  #   "activation": "2018-10-06T13:13:38",
  #   "expiry": "2018-10-06T14:13:38"
  # }

  #   {
  #   "locator": "AP9E60356",
  #   "product": {
  #     "media_type": 65,
  #     "id": "0111000000317",
  #     "description": "Reserva WEB (rotación)",
  #     "number": "11000000317",
  #     "barcode": "Q7015788547098903631470248212265410",
  #     "barcode_type": "QR",
  #     "door_pinpad_key": "30586"
  #   }
  # }

  # {
  #   "locator": "WR9E60358",
  #   "product": {
  #     "media_type": 65,
  #     "id": "0111000000319",
  #     "description": "Reserva WEB (rotación)",
  #     "number": "11000000319",
  #     "barcode": "Q9291346215529323111607540968582522",
  #     "barcode_type": "QR",
  #     "door_pinpad_key": "36382"
  #   }
  # }

  # {
  #   "locator": "AP9E60356",
  #   "created": "2018-09-11T19:04:19.540",
  #   "license_plate": "DDD",
  #   "product_type": "1",
  #   "activation": "2018-10-06T13:13:38.000",
  #   "expiry": "2018-10-06T14:13:38.997",
  #   "holder_name": "",
  #   "phone_number": "",
  #   "email": "",
  #   "remarks": "Localizador: AP9E60356",
  #   "reference_id": "",
  #   "amount_paid": 0,
  #   "automatic_use_by_license_plate": true,
  #   "available_balance": 0,
  #   "attached_product_group": "",
  #   "cancelled": false,
  #   "product": {
  #     "media_type": 65,
  #     "id": "0111000000317",
  #     "description": "Reserva WEB (rotación)",
  #     "number": "11000000317",
  #     "barcode": "Q0398038902272573011109219257420611",
  #     "door_pinpad_key": "30586",
  #     "first_use": null,
  #     "last_use": null,
  #     "status": {
  #       "presence_status": 1
  #     }
  #   }
  # }

  @doc """
  Cancels an existing reservation by puting Embers's API
  """
  def cancel_reservation(locator) do
    {domain, api_key, timezone, _} = get_config(:trindade_park)

    url = "#{domain}/porto-parking/reservations/#{locator}"

    put(url, api_key, %{
      cancelled: true,
      expiry:
        Timex.now(timezone) |> Timex.add(Timex.Duration.from_minutes(1)) |> format_date_time()
    })
    |> handle_http_response()
  end

  @doc """
  Deletes an existing reservation from Embers's API
  """
  def delete_reservation(locator) do
    {domain, api_key, _timezone, _} = get_config(:trindade_park)

    url = "#{domain}/porto-parking/reservations/#{locator}"

    delete(url, api_key)
    |> handle_http_response()
  end

  @doc """
  Makes the first step in the payment workflow by posting Embers's API
  """
  def payment1(barcode) do
    {domain, api_key, timezone, _} = get_config(:trindade_park)

    url = "#{domain}/porto-parking/payment1"

    post(url, api_key, %{
      barcode: barcode,
      now: Timex.now(timezone) |> format_date_time(),
      discounts: ""
    })
    |> handle_http_response()
  end

  # {
  #   "barcode": "string",
  #   "discounts": "string",
  #   "now": "string"
  # }
  # {
  #   "product_no": "SAGA product number (Ticket number)",
  #   "parking_start_time": "Parking start datetime (ISO8601 format, yyyy-mm-ddThh:nn:ss)",
  #   "parking_payment_time": "Parking payment datetime (ISO8601 format, yyyy-mm-ddThh:nn:ss)",
  #   "stay_time": "Stay time, in minutes",
  #   "parking_rate": "Parking rate code",
  #   "total_amount": "Total amount to pay",
  #   "discounts_amount": "Discounts amount",
  #   "outstanding_amount": "Amount to pay after applying discounts",
  #   "context_token": "Context token to use in payment2 request"
  # }

  @doc """
  Makes the second and final step in the payment workflow by posting Embers's API
  """
  def payment2(context_token) do
    {domain, api_key, _, _} = get_config(:trindade_park)

    url = "#{domain}/porto-parking/payment2"

    post(url, api_key, %{
      context_token: context_token,
      customer_name: ""
    })
    |> handle_http_response()
  end

  # {
  #   "context_token": "string",
  #   "customer_name": "string",
  #   "truncated_pan": "string",
  #   "bank_auth_no": "string"
  # }
  #
  # {
  #   "product_no": "SAGA product number (Ticket number)",
  #   "parking_start_time": "Parking start datetime (ISO8601 format, yyyy-mm-ddThh:nn:ss)",
  #   "parking_payment_time": "Parking payment datetime (ISO8601 format, yyyy-mm-ddThh:nn:ss)",
  #   "stay_time": "Stay time, in minutes",
  #   "parking_rate": "Parking rate code",
  #   "total_amount": "Total amount to pay",
  #   "discounts_amount": "Discounts amount",
  #   "amount_paid": "Payed amount",
  #   "receipt_no": "Receipt number",
  #   "shift_no": "Recorded shift number",
  #   "receipt_text": "Payment receipt"
  # }

  # {
  #       "parking_code": 1,
  #       "payment_id": "0175744591791",
  #       "payment_time": "2018-09-11T12:45:17.930",
  #       "payment_time_dst": true,
  #       "machine_payment_sequence_number": 1,
  #       "machine_type": 1,
  #       "machine_number": 1,
  #       "shift_code": "T18/101/0001",
  #       "total_amount": 300,
  #       "tax_rate": 21,
  #       "tax_rate2": 0,
  #       "tax_rate3": 0,
  #       "payment_method": 0,
  #       "paid_on_account": 300,
  #       "remarks": "Emisión de factura simplificada (Origen: 00118/402000011)",
  #       "receipt_copy_requested": true,
  #       "customer_parking_code": 1,
  #       "customer_code": 7,
  #       "teller_user_id": 6,
  #       "paid_on_foot": false,
  #       "receipts_remittance_number": "",
  #       "associated_cash_transaction_id": "",
  #       "business_name": "JC Rubio",
  #       "tin": "02259730A",
  #       "business_address": "direccion",
  #       "credit_card_last_digits": "",
  #       "credit_transaction_number": 0,
  #       "credit_tansaction_authorization": "",
  #       "invoice_id": "00118/101000001",
  #       "receipt": "========================================\r\n           Expo. Primavera 14           \r\n          EQUINSA Parking S.L.          \r\n            C/ Primavera, 14            \r\n         28850 Torrejón de Ardoz        \r\n             CIF: B-95786432            \r\n========================================\r\n 11/09/2018 12:45          T18/101/0001 \r\n Caja: 101             Cód. Operador: 6 \r\n        Núm Factura simplificada:       \r\n             00118/101000001            \r\n\r\n    Nombre: JC Rubio                    \r\n   CIF/NIF: 02259730A                   \r\n Domicilio: direccion\r\n - - - - - - - - - - - - - - - - - - - -\r\n                    1 x Artículo Manual\r\n         ** Cambio de ruedas **        \r\n      Importe:                 300,00 €\r\n----------------------------------------\r\n    Base Imp.:                 247,93 €\r\n  I.V.A.(21%):                  52,07 €\r\n                         ---------------\r\n    T O T A L:                 300,00 €\r\n========================================\r\n          Gracias por su visita         \r\n     Fecha emisión: 11/09/2018 12:45    \r\n========================================\r\n",
  #       "emv_receipt": "",
  #       "receipt_series": "",
  #       "payment_hash": ""
  #     }
end

# {
#  "early_transaction_id": "001180216113134102020002269",
#  "product_no": "02020002269",
#  "license_plate": "",
#  "parking_start_time": "2018-02-06T12:30:33.200",
#  "parking_payment_time": "2018-02-16T11:31:34.317",
#  "stay_time": 14341,
#  "parking_rate_code": 1,
#  "parking_rate_description": "Normal",
#  "total_amount": 100,
#  "discounts_amount": 0,
#  "outstanding_amount": 100,
#  "grace_period_minutes": 15,
#  "current_product_QR_code": "10202000226936893000",
#  "paid_product_QR_code": "10202000226936992765",
#  "courtesy_minutes_to_pay": 5,
#  "context_token": "eJx1U9tunDAQ\/ZUVT620iWxzWYjES\/ILeUtWq1nbu7GKMbHNqhf13zvGxkVJK0CcOTPDXI75VUzwQ8vR05OV77N0\/uSVlsVDwQht7wi7o80zpQ8l3tV9yepiv2ZgzAs35+OrfR3HWQvpexowN0KNLuM++XsSwEXyN2P7qqTVYV+1hNUt69omuJBP3iXSqwkmiBjTM54GCF8L0Enbpyp+ztBMMkUaq\/S0xWxrlNHADJwCnFnzL8AzNHaCa4zDDBw694NVPFhuZWa8hcQs2TPMgxfquuWWzfBBhWq5+MYcjbbw05nYwKguy1sYvVLm7OLkZuBmHQ2uDoa0XmVxGAcXP\/klcD6rm3xb4Akn8AZFImQ1E5NtIV00wvOCiuLH7unxH6qiIzZkReZQMW7GZEICXsm+23d1R6qGdXjXtEzrXDvBkNDFf6I2LccaDgc\/LE4hJ2vQyfAihLGmC\/RN2oX+23U2UaWAPyRg0NXOwcGCiSrjbxCOaHnY14wyeqg71qRVJ9en0xt6AxvLaIjLR1nCQkjCQrmsejwH20MQsTZRYPk9qXtCTVJ3X54ed5S1T193z4p\/k34n5A6btSAgaxYEs5IfPxJS3xau+P0HEhFqHw==",
#  "product_information": {
#    "media_raw_data": "5B6461745D0D0A64697361736F3D33300D0A636F646261723D31303230323030303232363933363839333030300D0A",
#    "media_type": 7,
#    "id": "102020002269",
#    "number": "02020002269",
#    "truncated_parking_code": 1,
#    "parking_code": 1,
#    "product_group_code": 2,
#    "product_group_code_description": "(CB 128C) Ticket de entrada",
#    "product_type": 1,
#    "producer_machine_number": 2,
#    "ordinal": 2269,
#    "product_version": 1,
#    "presence_status": 3,
#    "last_movement": "2018-02-06T12:30:33.200",
#    "last_movement_dst": false,
#    "paid": false,
#    "media_attached_product_groups": "",
#    "available_balance": 0,
#    "balance_readed_from_media": false,
#    "cancelled_mark": false,
#    "today_uses": 0,
#    "total_uses": 0,
#    "locked": false,
#    "antipassback": true,
#    "license_plate": "",
#    "creation_date": "2018-02-06T12:30:33.593",
#    "force_rate_code": 0,
#    "renewals_payment_control": false,
#    "customer_parking_code": 0,
#    "customer_code": 0,
#    "last_media_write": "2018-02-06T12:30:35.797",
#    "media_write_counter": 1,
#    "automatic_use_by_license_plate": false,
#    "old_subscriber_id": "",
#    "last_movement_license_plate": "",
#    "license_plate_image_path": "\\\\192.168.70.53\\Matriculas\\180206\\E2,180206123027500,180206,123027,---.JPG",
#    "skip_entry_license_plate_verification": false,
#    "skip_exit_license_plate_verification": false,
#    "holder_first_name": "",
#    "holder_last_name": "",
#    "holder_id_card": "",
#    "holder_title": "",
#    "place_number": "",
#    "remarks": "",
#    "last_movement_parking_code": 1,
#    "last_movement_machine_type": 5,
#    "last_movement_machine_number": 2,
#    "additional_data": "5B6461746164695D0D0A636F6467727570726F76696E3D340D0A666563686F7261637467727570726F76696E3D34333134372C343638363333313934340D0A",
#    "database_completed": true,
#    "in_use": true,
#    "courtesy_time_override": false
#  }
# }
