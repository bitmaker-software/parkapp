defmodule ParkappWeb.ApiIntegration.MBWay.HelpersTest do
  use Parkapp.DataCase

  alias ParkappWeb.ApiIntegration.MBWay.Helpers

  describe "MBWay Helpers" do
    @iv_from_http_header "3E7940F251810BA8FAF47BDB"
    @auth_tag_from_http_header "4734241E06525F7E3A2F6636C059DCBD"
    @http_body "B0220C0D031CBAAD031806716D81F6B42C61ABA40C57EB3637C9AAB1D2A801EC2CED98D1212CC36E8E386DB1243E515C8C24E42E6130B4A77680BA5934991A9C21CB6FB7D8B7145A97449AAC4DD86AAD5906EC25216440C9E1BA32578DD57888B366AA5A3F5B9A38D666155EC0BBA60B0A16051B805EF6E7BA3D4D8D1129304A76875FF29511999D65CF47B2C05620E0D55E0738AAB52EFCA1C91633A5F82B30A0D4F832DDD940D55B441CC59D87D1C840D73A1D21DAE8CD31FD03DF90016DE58BF04CB8BEDF7E46BA3A6D0380E67C738D38C698EBA71371B1B2AFA4F37953ED5D6DD4DBE249A5AF3B4B384444BF5D97467149C3B24E9C831D95C8D48E31572554C8A64D1CD250163475B5B68B8D50B999BDE1FA42B030436B231FFD3E056F0CCE9B36618DAEB2990936C3244AA854CF409A816E2DE4B07F150AA84371FE5C3CA04E0524A212CE061F0FA460BE5C33E0EA751B0760050D4E8190128DA81D9FE9428A983E4B51C4CFDB38B929941E557B3606E329934FD24D1B385F70DAD6E7CCAB6BC5B86902714B6061510291EC6E856D4FC9B1951BF93C720A350252867D4A1B8C7A1359FB6952818FCA6F506D4A7604580E395B3428FAD442C6C4EF2165EFC2D962BFB9B7AFCDA499B1259FB1387E712B9D89D4D0E3328F4979999CAADAE25FCE378EED5ACCB8FFF4D81552A5733A3BEA77B5D4606AA11F1FD6E1F6867DCA08CBC12B457348768F6122B4F4036AB55352A890299A5643C66BD8984067E8200F56E4604A6B55234704299BD2016D374BF51B3C6B7E13383B7E6AE9C94D4B740097F1201D5206BFCE72893913445B15F77DBD7228E8F7D43F2893714FB0676D40E7CD7A578B30F8221F4327FBB323B6AA9FE17E7E8AD3F205036E4EAFC6748218196E61FB628EC765F8CD6C3E3FAF028FC2C1CFBBDEB546FFC1F669642FA9789CF794A15201AC2B99CA33C16782A4AB57A935D3A80375B322D7F9CD7983E1DE10B42CE5A01713675E673AD630DDA8B3BB4F86005FAF0D647B25185019FC95A54A11EB94D9477C728BB9A57A011E14635BACC4087A425DC603EA4A128D56F0EE764F9085C4C9DD19B0B78402077365A49507874F505DE67977334AE1CC5B62B9A34C8DFC6193F990439D9B2C5DF3BA62CA901CCBA70FDE4496DD87B086FC9A5A09C2436943B81E8629213D4C866CC9DFC6021D0216A74BF456342BD109015B9D94A3BDB43C1B7A66FCCAF23BE029AE641E94F33BE2A8AD8882076B99BEA47F38A5DA1A8228E94E562258E83A0C7C32533CD5CBE9C5FED939FC06670CF0CDC5B37693657F5029F31165A5C9E59A9D7CCD12B77BC93A214745B8D6D36C5130E02A07FE16CA"

    test "decrypt_hexadecimal_response/3 should return the decrypted payload" do
      assert Helpers.decrypt_hexadecimal_response(
               @http_body,
               @auth_tag_from_http_header,
               @iv_from_http_header
             ) ==
               "{\"type\":\"PAYMENT\",\"payload\":{\"id\":\"8a82944966540bf4016668ad518b3366\",\"paymentType\":\"DB\",\"paymentBrand\":\"MBWAY\",\"amount\":\"10.0\",\"currency\":\"EUR\",\"presentationAmount\":\"10.0\",\"presentationCurrency\":\"EUR\",\"descriptor\":\"9871.0668.3394\",\"merchantTransactionId\":\"user token\",\"result\":{\"code\":\"000.100.110\",\"description\":\"Request successfully processed in 'Merchant in Integrator Test Mode'\",\"randomField1101240333\":\"Please allow for new unexpected fields to be added\"},\"resultDetails\":{\"AcquirerResponse\":\"APPR\",\"Pre-authorization validity\":\"2018-09-15T01:00:00.001+01:00\",\"ConnectorTxID1\":\"8a82944966540bf4016668ad518b3366\",\"ConnectorTxID3\":\"540bf4016668ad518b3366\",\"ConnectorTxID2\":\"8a829449\"},\"authentication\":{\"entityId\":\"8a8294185bd901c5015be855fd5f1578\"},\"redirect\":{\"parameters\":[]},\"risk\":{\"score\":\"\"},\"timestamp\":\"2018-10-12 14:28:06+0000\",\"ndc\":\"8a8294185bd901c5015be855fd5f1578_c4e85e97008f4f21acfafeb3044bac33\",\"virtualAccount\":{\"accountId\":\"351#911222111\"}}}"
    end

    test "decrypt_hexadecimal_response/3 should return nil if the arguments are not hexadecimal" do
      error_message = :error

      assert Helpers.decrypt_hexadecimal_response(
               "",
               @auth_tag_from_http_header,
               @iv_from_http_header
             ) == error_message

      assert Helpers.decrypt_hexadecimal_response(
               @http_body,
               "",
               @iv_from_http_header
             ) == error_message

      assert Helpers.decrypt_hexadecimal_response(
               @http_body,
               @auth_tag_from_http_header,
               ""
             ) == error_message

      assert Helpers.decrypt_hexadecimal_response(
               "http_body",
               @auth_tag_from_http_header,
               @iv_from_http_header
             ) == error_message

      assert Helpers.decrypt_hexadecimal_response(
               @http_body,
               "auth_tag_from_http_header",
               @iv_from_http_header
             ) == error_message

      assert Helpers.decrypt_hexadecimal_response(
               @http_body,
               @auth_tag_from_http_header,
               "iv_from_http_header"
             ) == error_message
    end

    test "decrypt_hexadecimal_response/3 should decrypt something encrypted by us as well" do
      iv_from_http_header = Base.decode16!(@iv_from_http_header, case: :mixed)

      http_body = "{\"type\": \"cenas\"}"

      secret_from_config =
        Application.get_env(:parkapp, :mb_way_api, [])
        |> Enum.into(%{})
        |> Map.get(:decrypt_secret, "")
        |> Base.decode16!(case: :mixed)

      {http_body_encrypted, auth_tag_from_http_header} =
        :crypto.block_encrypt(
          :aes_gcm,
          secret_from_config,
          iv_from_http_header,
          {"", http_body}
        )

      http_body_encrypted =
        http_body_encrypted
        |> Base.encode16()

      auth_tag_from_http_header =
        auth_tag_from_http_header
        |> Base.encode16()

      assert Helpers.decrypt_hexadecimal_response(
               http_body_encrypted,
               auth_tag_from_http_header,
               @iv_from_http_header
             ) == http_body
    end
  end
end
