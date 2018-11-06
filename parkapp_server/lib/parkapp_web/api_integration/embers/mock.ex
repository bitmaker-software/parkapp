defmodule ParkappWeb.ApiIntegration.Embers.Mock do
  @moduledoc """
    Mock implementation of the Embers API. Used for testing.
  """

  @behaviour ParkappWeb.ApiIntegration.Embers.Behaviour

  def get_route(_from, _to, _mode) do
    {
      :ok,
      %{
        "plan" => %{
          "date" => 1_536_656_665_000,
          "fromPlace" => %{
            "lat" => "50.93633658100821",
            "lon" => "6.976017951965332",
            "name" => "",
            "orig" => "",
            "vertexType" => ""
          },
          "itineraries" => [
            %{
              "legs" => [
                %{
                  "distance" => 4714.9,
                  "instructions" => [
                    "Head northeast on Reischplatz",
                    "Turn right onto Deutzer Freiheit",
                    "Turn left onto Graf-Geßler-Straße",
                    "Make a sharp left onto Kasemattenstraße",
                    "Turn right onto Neuhöfferstraße",
                    "Turn left onto Siegesstraße",
                    "Turn right onto Mindener Straße (L 111)",
                    "Make a U-turn towards Zentrum",
                    "Continue straight onto Deutzer Brücke (L 111)",
                    "Continue straight towards Dom/Hbf",
                    "Continue straight onto Augustinerstraße (L 111)",
                    "Continue straight onto Pipinstraße (L 111)",
                    "Continue straight onto Cäcilienstraße (L 111)",
                    "Turn right onto Nord-Süd-Fahrt",
                    "Continue straight onto Offenbachplatz",
                    "Continue straight onto Tunisstraße",
                    "Continue slightly left onto Tunisstraße",
                    "Go straight onto Komödienstraße",
                    "Continue straight onto Zeughausstraße",
                    "Continue straight onto Magnusstraße",
                    "Continue straight onto Friesenplatz (B 59)",
                    "Continue straight onto Venloer Straße (B 59)",
                    "Turn right onto Spichernstraße",
                    "You have arrived at your destination"
                  ],
                  "mode" => "CAR",
                  "route" =>
                    "ao{uHeoqi@k@mAIOk@?MECi@gFi@FNBXATGRKLCFe@nAo@pAy@dBI@\\|ETtC@RD\\BXF~@NxAAXCJCDADMTQCOGOIMEMIKIWWUUUa@Y?CBEBEJ?HBPPXl@v@j@d@f@Vf@LRD\\D`DT`@HZJXRLLNNLTHTJXJj@D|@DbA@v@B|@H~Ez@|\\B|@@N?XDjAB`@B\\D`@PtANdAJj@FZ@JHn@@\\FzABn@DZHj@f@dDDTBRLl@Fj@Dp@Bb@?TB`@@VDh@Dj@BR@HBTD\\Dx@@h@@~@A|@?`@C`@Ef@Eh@MlAQX[f@}B`AmANm@LcAAk@GSEWGKEq@QaA]MGMEIAIEC?ECmAWGAOAO?E@q@DyAPA?oAJKKi@DwANa@DIBC?]JEDIDIRGLELERIZ?|@BzCBnB?t@Bj@FnABf@@LHdBFdBFt@Dn@Dp@J\\D\\?FD`@?XANAF?DAPA\\?R@^@VBXDTHZBJHZJXf@dATf@P^LZHXBJLv@Lz@VtBBb@@V@d@?bAGvA?LIv@Kt@WnAMl@Kj@Mn@KdAAd@AP?RALGzAAp@UdBEb@Kj@ANGTG^EHi@dAeAxBq@tA}AvDo@cA{@oAaDsEe@q@IM??s@oAyAoC"
                }
              ]
            }
          ],
          "toPlace" => %{
            "lat" => "50.944557395196654",
            "lon" => "6.938767433166504",
            "name" => "",
            "orig" => "",
            "vertexType" => ""
          }
        },
        "requestParameters" => %{
          "arriveBy" => false,
          "fromPlace" => "50.93633658100821,6.976017951965332",
          "maxWalkDistance" => "500",
          "mode" => "CAR",
          "time" => "11:04",
          "toPlace" => "50.944557395196654,6.938767433166504",
          "wheelchair" => false
        }
      }
    }
  end

  def get_reservation(_locator) do
    {:ok,
     %{
       "reservations" => [
         %{
           "product" => %{
             "barcode" => "some barcode",
             "presence_status" => 3
           },
           "locator" => "some locator",
           "activation" => DateTime.utc_now(),
           "expiry" => DateTime.utc_now(),
           "cancelled" => false
         }
       ]
     }}
  end

  def make_reservation(_product_type) do
    {:ok,
     %{
       "product" => %{
         "barcode" => "some barcode"
       },
       "locator" => "some locator"
     }}
  end

  def cancel_reservation(_locator) do
    {:ok,
     %{
       "activation" => "2018-09-18T11:11:26.000",
       "amount_paid" => 0,
       "attached_product_group" => "0",
       "automatic_use_by_license_plate" => true,
       "available_balance" => 0,
       "cancelled" => true,
       "created" => "2018-09-18T11:11:26.833",
       "email" => "",
       "expiry" => "2018-09-18T11:12:26.000",
       "holder_name" => "",
       "license_plate" => "",
       "locator" => "WW9E60449",
       "phone_number" => "",
       "product" => %{
         "barcode" => "Q1730463835940490021679061827538105",
         "description" => "",
         "door_pinpad_key" => "47133",
         "first_use" => nil,
         "id" => "0111000000409",
         "last_use" => nil,
         "media_type" => 65,
         "number" => "11000000409",
         "status" => %{"presence_status" => nil}
       },
       "product_type" => "1",
       "reference_id" => "127.0.0.1",
       "remarks" => "Localizador: WW9E60449"
     }}
  end

  def delete_reservation(_locator) do
    {:ok, nil}
  end

  def payment1(_barcode) do
    {:ok,
     %{
       "context_token" => "some context token",
       "parking_start_time" => DateTime.utc_now(),
       "parking_payment_time" => nil,
       "outstanding_amount" => "10.00"
     }}
  end

  def payment2(_context_token) do
    :ok
  end
end
