defmodule ParkappWeb.RSATest do
  use ParkappWeb.ConnCase
  alias ParkappWeb.Auth.RSA.RSACrypto
  alias ParkappWeb.Auth.RSA.KeyLoader
  alias ParkappWeb.Auth

  test "RSAAuthentication encrypt_message_public" do
    message =
      "2Zk4u7TIHqS0ydRv2ByyZcRYqoeHKy_YuB8JItpwjTTnWx_i3Twknr46JYMTNjM8v99V7H4xeF6LJ5qjd08Q1IniR-Ih2N7TfK9yNWQQ71sKzwxhAdB67VHt5Vg2jTQ-GGiF7UMJrjMyXyD5dqb6idOuqKhvNQJFO79Av1jZ3MhMbztLcmdwZCJFfIdKoSfD0HfWlXX9vDjKjsuIXmqwxNReKvzLucwhKEtEMkcZ7geRxdTPzCCpcucDX-6kZMBl"

    public_key_string = "MIIBCgKCAQEAp9BCdNzjjBn5j9h8xIZXW1MWjfA2WL0mA0x9pR0qOm5ESGq4nF2L
    SPbKw4TetnmDHQVq5rIKTkBa8prjKR4MSCn1/S//coB62JsDuxw1VjgW52RmoSm+
    19bS1JoNsD+Js0rrZpMuy0TiV9ssI3OqBjx0WuHOHhXMz+Mu4DOqZPjUwHkMf5sC
    7bGn2R7oQnhbz9lJ96hDFZuN7IEKGaE4sgCqR+5FdRL4LXME7pw76xi+qv+GqUE/
    gxeqdOCjI4ALOk2fk3DWtBQv4rLEbyDwqpGwknG2E+udOrQgyd39Mitbhn3eGrto
    /wWN+/2jkWq6CC10h7z1bObRVK3EjlL7sQIDAQAB"
    public_key = KeyLoader.load_public_key(public_key_string)

    encrypted_message = RSACrypto.encrypt_message_public(public_key, message)

    expected_encrypted_message =
      "lEW3GLT1yePFmLgX8piFy/1Ei2syMzdYvreJC0t58lSaDONJm5Ef6UkXQoF3L4K9ZwOoIF+XvyZwAjlts0//Yvtaz9lNbBJhScenMkeYHjjbWPqHG5p1fNZwcsWMSbkUAYTDBRR4+UVcthHOQPctZcZMlSLr/uOK4/0BhdyRTAx3iSs4aIx89sCeQfUOe345aa/EJlw7mZEd8OncbUQmP2mdo3scPzxjKrHgkaK+dcNDA5pfucNgXTis0s977Wb4OlhgrTceBtEyvb8KYfrh7ZJB/0MnPsV4WFRbkAsIuTC2nNmkbqa+FZqysT5JbWqeSvZaRnBQO0nP94co5cl/0A=="

    assert(encrypted_message == expected_encrypted_message)
  end

  test "RSAAuthentication encrypt_message_private" do
    message =
      "2Zk4u7TIHqS0ydRv2ByyZcRYqoeHKy_YuB8JItpwjTTnWx_i3Twknr46JYMTNjM8v99V7H4xeF6LJ5qjd08Q1IniR-Ih2N7TfK9yNWQQ71sKzwxhAdB67VHt5Vg2jTQ-GGiF7UMJrjMyXyD5dqb6idOuqKhvNQJFO79Av1jZ3MhMbztLcmdwZCJFfIdKoSfD0HfWlXX9vDjKjsuIXmqwxNReKvzLucwhKEtEMkcZ7geRxdTPzCCpcucDX-6kZMBl"

    private_key_string = "MIIEogIBAAKCAQEAp9BCdNzjjBn5j9h8xIZXW1MWjfA2WL0mA0x9pR0qOm5ESGq4
    nF2LSPbKw4TetnmDHQVq5rIKTkBa8prjKR4MSCn1/S//coB62JsDuxw1VjgW52Rm
    oSm+19bS1JoNsD+Js0rrZpMuy0TiV9ssI3OqBjx0WuHOHhXMz+Mu4DOqZPjUwHkM
    f5sC7bGn2R7oQnhbz9lJ96hDFZuN7IEKGaE4sgCqR+5FdRL4LXME7pw76xi+qv+G
    qUE/gxeqdOCjI4ALOk2fk3DWtBQv4rLEbyDwqpGwknG2E+udOrQgyd39Mitbhn3e
    Grto/wWN+/2jkWq6CC10h7z1bObRVK3EjlL7sQIDAQABAoIBACWLHDMU7/t6HDEo
    V9GH1Kdj0Vnz8dSsjIKUbE+yVK452SDyb1bcPrsWK4rOgR0F1mV5vs7Z6iBTmYVJ
    TaT3SfwjFxuLz3SIdfNbytvjlbMyXT1rYuKPeljDgOt7g7B4po/sJPoP15o2UQUi
    zZ8o01MN12I1vm1Qpz+jLeuO44IvJEa+VSsyYxy6KcFWX0ZV2PkEUYF8oq6C7qUV
    HW9d4a/2ByldEoaP2eKKzJ+Ae2KR/vnKW+P2yBQ3cEtKfSCcFx1S8krJBqiNcT8m
    gxbgK5ihaSF3C6x0cRNgiSlaq4ZBwKoLCQFlNnpsGQgFLMViS8vbaCv7aoEcLbWL
    aHZT/9kCgYEA3Zzx+j9mkHDHIWmqz0IS5dYPkKWXwUMw6o+bjrpr75OMRloTB9Xa
    kEC4Y9reJ8Y4S6tdDr3blc3Tu0yPZeDnTqEw74aVqFy4Tr6OsZeTehG0rHmJmFZZ
    CH8l6BvdAk0QagCfzNF8b85h78kFMWS48OtzcgeL/GU5rf8GvaX0LQcCgYEAwdpB
    IK5Z12NMHmHDN1W4wfJupJTUVi/D1szR4fWEQbf4BRizDKuTVJJyxyt4DFamGwDe
    U8V/OUhSoG9C8xr50db9VgfW7jM/6XEb98ofCY/w7LhrSp8nss1WMzL7nzaWMhgM
    dUpBPtPGuOk3JhvPM+VAl3sik8CRHiLk1etUm4cCgYBZqQzRlWMWnzpBj3HXBsGE
    kZWcjRKX02pwDAgAt/XBaS3ArOK0MdaKtFSlucBV0UGng75Tn4a+1haK2c/OhS6w
    RlD5J7dW9aRv33L18QBuy8kQWt/LbWv6Hw8kGFnTe4Bfkr8Ua9Dvn01KaUcbk8er
    WWdMxDbjt8SdW+fLROBEcwKBgCGQO2SAK3f6bkx4Wsdy5RlXc0a1qgn+HSdMsS4x
    RyPlyWCAhUe1UT38WTkY0qE4Q2w7e0L/1+ZAGmZCvVHAIu7tDVHe65y0bOVrOw9t
    BHCwZmNmDtWNtt7jZIBa3GwVlG258jZAlAlfu3F6l5zWhcqTb9qKbFMurTGNkxdi
    tnRzAoGAVJT6iJKuVQzeq54oKX+yDXkwGqznrRJn3cPoOoxLt8LyQ9+vi+nlegOt
    bDC+Y3++mTxuEBa6rJxKuONLue+cJqXM8aVaidC7aMCvZhXZtjU0MI6XC72tM96C
    xYQKxVQjbOyY3PG4CrQXGfahYkX6ldxET/g3DOwV69XQVNUtL1Y="
    private_key = KeyLoader.load_private_key(private_key_string)

    encrypted_message = RSACrypto.encrypt_message_private(private_key, message)

    expected_encrypted_message =
      "a3vaf8tOHX88AGp5gjf9nHZf3/Y+WWe420caub/xUhxovd7L1Cv6OJgJShSS7mah+NVKrGRfOdUS/F6t5C7I6IzmCFbJ1zCX2KZw3z2YhbaK1Mxbn/k6C9dhvlTGdsmhypPAVULlrCp5eMfPI7lVd18w3jnSPx9TaRQYwdAnTHTW6v1tA4B8eySJSLZ5h7vKV7BuAILgfOPEWfUXk/SV9MSMSAfHBTaCmeYfezztWrU2GVwbg9S/qy/ruRMminQ7euPh4diTNOs4+YxDb2FcjIp2XtzE1/Ka3mjoRsJLqHv1lE1J8CtkeGXFbCfMNUoxwONynjeIz5tut92yxWkGjA=="

    assert(encrypted_message == expected_encrypted_message)
  end

  test "RSAAuthentication decrypt_message_public" do
    encrypted_message =
      "a3vaf8tOHX88AGp5gjf9nHZf3/Y+WWe420caub/xUhxovd7L1Cv6OJgJShSS7mah+NVKrGRfOdUS/F6t5C7I6IzmCFbJ1zCX2KZw3z2YhbaK1Mxbn/k6C9dhvlTGdsmhypPAVULlrCp5eMfPI7lVd18w3jnSPx9TaRQYwdAnTHTW6v1tA4B8eySJSLZ5h7vKV7BuAILgfOPEWfUXk/SV9MSMSAfHBTaCmeYfezztWrU2GVwbg9S/qy/ruRMminQ7euPh4diTNOs4+YxDb2FcjIp2XtzE1/Ka3mjoRsJLqHv1lE1J8CtkeGXFbCfMNUoxwONynjeIz5tut92yxWkGjA=="

    public_key_string = "MIIBCgKCAQEAp9BCdNzjjBn5j9h8xIZXW1MWjfA2WL0mA0x9pR0qOm5ESGq4nF2L
    SPbKw4TetnmDHQVq5rIKTkBa8prjKR4MSCn1/S//coB62JsDuxw1VjgW52RmoSm+
    19bS1JoNsD+Js0rrZpMuy0TiV9ssI3OqBjx0WuHOHhXMz+Mu4DOqZPjUwHkMf5sC
    7bGn2R7oQnhbz9lJ96hDFZuN7IEKGaE4sgCqR+5FdRL4LXME7pw76xi+qv+GqUE/
    gxeqdOCjI4ALOk2fk3DWtBQv4rLEbyDwqpGwknG2E+udOrQgyd39Mitbhn3eGrto
    /wWN+/2jkWq6CC10h7z1bObRVK3EjlL7sQIDAQAB"
    public_key = KeyLoader.load_public_key(public_key_string)

    message = RSACrypto.decrypt_message_public(public_key, encrypted_message)

    expected_message =
      "2Zk4u7TIHqS0ydRv2ByyZcRYqoeHKy_YuB8JItpwjTTnWx_i3Twknr46JYMTNjM8v99V7H4xeF6LJ5qjd08Q1IniR-Ih2N7TfK9yNWQQ71sKzwxhAdB67VHt5Vg2jTQ-GGiF7UMJrjMyXyD5dqb6idOuqKhvNQJFO79Av1jZ3MhMbztLcmdwZCJFfIdKoSfD0HfWlXX9vDjKjsuIXmqwxNReKvzLucwhKEtEMkcZ7geRxdTPzCCpcucDX-6kZMBl"

    assert(message == expected_message)
  end

  test "RSAAuthentication decrypt_message_private" do
    encrypted_message =
      "lEW3GLT1yePFmLgX8piFy/1Ei2syMzdYvreJC0t58lSaDONJm5Ef6UkXQoF3L4K9ZwOoIF+XvyZwAjlts0//Yvtaz9lNbBJhScenMkeYHjjbWPqHG5p1fNZwcsWMSbkUAYTDBRR4+UVcthHOQPctZcZMlSLr/uOK4/0BhdyRTAx3iSs4aIx89sCeQfUOe345aa/EJlw7mZEd8OncbUQmP2mdo3scPzxjKrHgkaK+dcNDA5pfucNgXTis0s977Wb4OlhgrTceBtEyvb8KYfrh7ZJB/0MnPsV4WFRbkAsIuTC2nNmkbqa+FZqysT5JbWqeSvZaRnBQO0nP94co5cl/0A=="

    private_key_string = "MIIEogIBAAKCAQEAp9BCdNzjjBn5j9h8xIZXW1MWjfA2WL0mA0x9pR0qOm5ESGq4
    nF2LSPbKw4TetnmDHQVq5rIKTkBa8prjKR4MSCn1/S//coB62JsDuxw1VjgW52Rm
    oSm+19bS1JoNsD+Js0rrZpMuy0TiV9ssI3OqBjx0WuHOHhXMz+Mu4DOqZPjUwHkM
    f5sC7bGn2R7oQnhbz9lJ96hDFZuN7IEKGaE4sgCqR+5FdRL4LXME7pw76xi+qv+G
    qUE/gxeqdOCjI4ALOk2fk3DWtBQv4rLEbyDwqpGwknG2E+udOrQgyd39Mitbhn3e
    Grto/wWN+/2jkWq6CC10h7z1bObRVK3EjlL7sQIDAQABAoIBACWLHDMU7/t6HDEo
    V9GH1Kdj0Vnz8dSsjIKUbE+yVK452SDyb1bcPrsWK4rOgR0F1mV5vs7Z6iBTmYVJ
    TaT3SfwjFxuLz3SIdfNbytvjlbMyXT1rYuKPeljDgOt7g7B4po/sJPoP15o2UQUi
    zZ8o01MN12I1vm1Qpz+jLeuO44IvJEa+VSsyYxy6KcFWX0ZV2PkEUYF8oq6C7qUV
    HW9d4a/2ByldEoaP2eKKzJ+Ae2KR/vnKW+P2yBQ3cEtKfSCcFx1S8krJBqiNcT8m
    gxbgK5ihaSF3C6x0cRNgiSlaq4ZBwKoLCQFlNnpsGQgFLMViS8vbaCv7aoEcLbWL
    aHZT/9kCgYEA3Zzx+j9mkHDHIWmqz0IS5dYPkKWXwUMw6o+bjrpr75OMRloTB9Xa
    kEC4Y9reJ8Y4S6tdDr3blc3Tu0yPZeDnTqEw74aVqFy4Tr6OsZeTehG0rHmJmFZZ
    CH8l6BvdAk0QagCfzNF8b85h78kFMWS48OtzcgeL/GU5rf8GvaX0LQcCgYEAwdpB
    IK5Z12NMHmHDN1W4wfJupJTUVi/D1szR4fWEQbf4BRizDKuTVJJyxyt4DFamGwDe
    U8V/OUhSoG9C8xr50db9VgfW7jM/6XEb98ofCY/w7LhrSp8nss1WMzL7nzaWMhgM
    dUpBPtPGuOk3JhvPM+VAl3sik8CRHiLk1etUm4cCgYBZqQzRlWMWnzpBj3HXBsGE
    kZWcjRKX02pwDAgAt/XBaS3ArOK0MdaKtFSlucBV0UGng75Tn4a+1haK2c/OhS6w
    RlD5J7dW9aRv33L18QBuy8kQWt/LbWv6Hw8kGFnTe4Bfkr8Ua9Dvn01KaUcbk8er
    WWdMxDbjt8SdW+fLROBEcwKBgCGQO2SAK3f6bkx4Wsdy5RlXc0a1qgn+HSdMsS4x
    RyPlyWCAhUe1UT38WTkY0qE4Q2w7e0L/1+ZAGmZCvVHAIu7tDVHe65y0bOVrOw9t
    BHCwZmNmDtWNtt7jZIBa3GwVlG258jZAlAlfu3F6l5zWhcqTb9qKbFMurTGNkxdi
    tnRzAoGAVJT6iJKuVQzeq54oKX+yDXkwGqznrRJn3cPoOoxLt8LyQ9+vi+nlegOt
    bDC+Y3++mTxuEBa6rJxKuONLue+cJqXM8aVaidC7aMCvZhXZtjU0MI6XC72tM96C
    xYQKxVQjbOyY3PG4CrQXGfahYkX6ldxET/g3DOwV69XQVNUtL1Y="
    private_key = KeyLoader.load_private_key(private_key_string)

    message = RSACrypto.decrypt_message_private(private_key, encrypted_message)

    expected_message =
      "2Zk4u7TIHqS0ydRv2ByyZcRYqoeHKy_YuB8JItpwjTTnWx_i3Twknr46JYMTNjM8v99V7H4xeF6LJ5qjd08Q1IniR-Ih2N7TfK9yNWQQ71sKzwxhAdB67VHt5Vg2jTQ-GGiF7UMJrjMyXyD5dqb6idOuqKhvNQJFO79Av1jZ3MhMbztLcmdwZCJFfIdKoSfD0HfWlXX9vDjKjsuIXmqwxNReKvzLucwhKEtEMkcZ7geRxdTPzCCpcucDX-6kZMBl"

    assert(message == expected_message)
  end

  test "RSAAuthentication EncryptPriv - DecryptPub" do
    message =
      "2Zk4u7TIHqS0ydRv2ByyZcRYqoeHKy_YuB8JItpwjTTnWx_i3Twknr46JYMTNjM8v99V7H4xeF6LJ5qjd08Q1IniR-Ih2N7TfK9yNWQQ71sKzwxhAdB67VHt5Vg2jTQ-GGiF7UMJrjMyXyD5dqb6idOuqKhvNQJFO79Av1jZ3MhMbztLcmdwZCJFfIdKoSfD0HfWlXX9vDjKjsuIXmqwxNReKvzLucwhKEtEMkcZ7geRxdTPzCCpcucDX-6kZMBl"

    public_key_string = "MIIBCgKCAQEAp9BCdNzjjBn5j9h8xIZXW1MWjfA2WL0mA0x9pR0qOm5ESGq4nF2L
    SPbKw4TetnmDHQVq5rIKTkBa8prjKR4MSCn1/S//coB62JsDuxw1VjgW52RmoSm+
    19bS1JoNsD+Js0rrZpMuy0TiV9ssI3OqBjx0WuHOHhXMz+Mu4DOqZPjUwHkMf5sC
    7bGn2R7oQnhbz9lJ96hDFZuN7IEKGaE4sgCqR+5FdRL4LXME7pw76xi+qv+GqUE/
    gxeqdOCjI4ALOk2fk3DWtBQv4rLEbyDwqpGwknG2E+udOrQgyd39Mitbhn3eGrto
    /wWN+/2jkWq6CC10h7z1bObRVK3EjlL7sQIDAQAB"
    private_key_string = "MIIEogIBAAKCAQEAp9BCdNzjjBn5j9h8xIZXW1MWjfA2WL0mA0x9pR0qOm5ESGq4
    nF2LSPbKw4TetnmDHQVq5rIKTkBa8prjKR4MSCn1/S//coB62JsDuxw1VjgW52Rm
    oSm+19bS1JoNsD+Js0rrZpMuy0TiV9ssI3OqBjx0WuHOHhXMz+Mu4DOqZPjUwHkM
    f5sC7bGn2R7oQnhbz9lJ96hDFZuN7IEKGaE4sgCqR+5FdRL4LXME7pw76xi+qv+G
    qUE/gxeqdOCjI4ALOk2fk3DWtBQv4rLEbyDwqpGwknG2E+udOrQgyd39Mitbhn3e
    Grto/wWN+/2jkWq6CC10h7z1bObRVK3EjlL7sQIDAQABAoIBACWLHDMU7/t6HDEo
    V9GH1Kdj0Vnz8dSsjIKUbE+yVK452SDyb1bcPrsWK4rOgR0F1mV5vs7Z6iBTmYVJ
    TaT3SfwjFxuLz3SIdfNbytvjlbMyXT1rYuKPeljDgOt7g7B4po/sJPoP15o2UQUi
    zZ8o01MN12I1vm1Qpz+jLeuO44IvJEa+VSsyYxy6KcFWX0ZV2PkEUYF8oq6C7qUV
    HW9d4a/2ByldEoaP2eKKzJ+Ae2KR/vnKW+P2yBQ3cEtKfSCcFx1S8krJBqiNcT8m
    gxbgK5ihaSF3C6x0cRNgiSlaq4ZBwKoLCQFlNnpsGQgFLMViS8vbaCv7aoEcLbWL
    aHZT/9kCgYEA3Zzx+j9mkHDHIWmqz0IS5dYPkKWXwUMw6o+bjrpr75OMRloTB9Xa
    kEC4Y9reJ8Y4S6tdDr3blc3Tu0yPZeDnTqEw74aVqFy4Tr6OsZeTehG0rHmJmFZZ
    CH8l6BvdAk0QagCfzNF8b85h78kFMWS48OtzcgeL/GU5rf8GvaX0LQcCgYEAwdpB
    IK5Z12NMHmHDN1W4wfJupJTUVi/D1szR4fWEQbf4BRizDKuTVJJyxyt4DFamGwDe
    U8V/OUhSoG9C8xr50db9VgfW7jM/6XEb98ofCY/w7LhrSp8nss1WMzL7nzaWMhgM
    dUpBPtPGuOk3JhvPM+VAl3sik8CRHiLk1etUm4cCgYBZqQzRlWMWnzpBj3HXBsGE
    kZWcjRKX02pwDAgAt/XBaS3ArOK0MdaKtFSlucBV0UGng75Tn4a+1haK2c/OhS6w
    RlD5J7dW9aRv33L18QBuy8kQWt/LbWv6Hw8kGFnTe4Bfkr8Ua9Dvn01KaUcbk8er
    WWdMxDbjt8SdW+fLROBEcwKBgCGQO2SAK3f6bkx4Wsdy5RlXc0a1qgn+HSdMsS4x
    RyPlyWCAhUe1UT38WTkY0qE4Q2w7e0L/1+ZAGmZCvVHAIu7tDVHe65y0bOVrOw9t
    BHCwZmNmDtWNtt7jZIBa3GwVlG258jZAlAlfu3F6l5zWhcqTb9qKbFMurTGNkxdi
    tnRzAoGAVJT6iJKuVQzeq54oKX+yDXkwGqznrRJn3cPoOoxLt8LyQ9+vi+nlegOt
    bDC+Y3++mTxuEBa6rJxKuONLue+cJqXM8aVaidC7aMCvZhXZtjU0MI6XC72tM96C
    xYQKxVQjbOyY3PG4CrQXGfahYkX6ldxET/g3DOwV69XQVNUtL1Y="
    private_key = KeyLoader.load_private_key(private_key_string)
    public_key = KeyLoader.load_public_key(public_key_string)

    encrypted_message = RSACrypto.encrypt_message_private(private_key, message)
    decrypted_message = RSACrypto.decrypt_message_public(public_key, encrypted_message)
    assert(message == decrypted_message)
  end

  test "RSAAuthentication EncryptPub - DecryptPriv" do
    message =
      "2Zk4u7TIHqS0ydRv2ByyZcRYqoeHKy_YuB8JItpwjTTnWx_i3Twknr46JYMTNjM8v99V7H4xeF6LJ5qjd08Q1IniR-Ih2N7TfK9yNWQQ71sKzwxhAdB67VHt5Vg2jTQ-GGiF7UMJrjMyXyD5dqb6idOuqKhvNQJFO79Av1jZ3MhMbztLcmdwZCJFfIdKoSfD0HfWlXX9vDjKjsuIXmqwxNReKvzLucwhKEtEMkcZ7geRxdTPzCCpcucDX-6kZMBl"

    public_key_string = "MIIBCgKCAQEAp9BCdNzjjBn5j9h8xIZXW1MWjfA2WL0mA0x9pR0qOm5ESGq4nF2L
    SPbKw4TetnmDHQVq5rIKTkBa8prjKR4MSCn1/S//coB62JsDuxw1VjgW52RmoSm+
    19bS1JoNsD+Js0rrZpMuy0TiV9ssI3OqBjx0WuHOHhXMz+Mu4DOqZPjUwHkMf5sC
    7bGn2R7oQnhbz9lJ96hDFZuN7IEKGaE4sgCqR+5FdRL4LXME7pw76xi+qv+GqUE/
    gxeqdOCjI4ALOk2fk3DWtBQv4rLEbyDwqpGwknG2E+udOrQgyd39Mitbhn3eGrto
    /wWN+/2jkWq6CC10h7z1bObRVK3EjlL7sQIDAQAB"
    private_key_string = "MIIEogIBAAKCAQEAp9BCdNzjjBn5j9h8xIZXW1MWjfA2WL0mA0x9pR0qOm5ESGq4
    nF2LSPbKw4TetnmDHQVq5rIKTkBa8prjKR4MSCn1/S//coB62JsDuxw1VjgW52Rm
    oSm+19bS1JoNsD+Js0rrZpMuy0TiV9ssI3OqBjx0WuHOHhXMz+Mu4DOqZPjUwHkM
    f5sC7bGn2R7oQnhbz9lJ96hDFZuN7IEKGaE4sgCqR+5FdRL4LXME7pw76xi+qv+G
    qUE/gxeqdOCjI4ALOk2fk3DWtBQv4rLEbyDwqpGwknG2E+udOrQgyd39Mitbhn3e
    Grto/wWN+/2jkWq6CC10h7z1bObRVK3EjlL7sQIDAQABAoIBACWLHDMU7/t6HDEo
    V9GH1Kdj0Vnz8dSsjIKUbE+yVK452SDyb1bcPrsWK4rOgR0F1mV5vs7Z6iBTmYVJ
    TaT3SfwjFxuLz3SIdfNbytvjlbMyXT1rYuKPeljDgOt7g7B4po/sJPoP15o2UQUi
    zZ8o01MN12I1vm1Qpz+jLeuO44IvJEa+VSsyYxy6KcFWX0ZV2PkEUYF8oq6C7qUV
    HW9d4a/2ByldEoaP2eKKzJ+Ae2KR/vnKW+P2yBQ3cEtKfSCcFx1S8krJBqiNcT8m
    gxbgK5ihaSF3C6x0cRNgiSlaq4ZBwKoLCQFlNnpsGQgFLMViS8vbaCv7aoEcLbWL
    aHZT/9kCgYEA3Zzx+j9mkHDHIWmqz0IS5dYPkKWXwUMw6o+bjrpr75OMRloTB9Xa
    kEC4Y9reJ8Y4S6tdDr3blc3Tu0yPZeDnTqEw74aVqFy4Tr6OsZeTehG0rHmJmFZZ
    CH8l6BvdAk0QagCfzNF8b85h78kFMWS48OtzcgeL/GU5rf8GvaX0LQcCgYEAwdpB
    IK5Z12NMHmHDN1W4wfJupJTUVi/D1szR4fWEQbf4BRizDKuTVJJyxyt4DFamGwDe
    U8V/OUhSoG9C8xr50db9VgfW7jM/6XEb98ofCY/w7LhrSp8nss1WMzL7nzaWMhgM
    dUpBPtPGuOk3JhvPM+VAl3sik8CRHiLk1etUm4cCgYBZqQzRlWMWnzpBj3HXBsGE
    kZWcjRKX02pwDAgAt/XBaS3ArOK0MdaKtFSlucBV0UGng75Tn4a+1haK2c/OhS6w
    RlD5J7dW9aRv33L18QBuy8kQWt/LbWv6Hw8kGFnTe4Bfkr8Ua9Dvn01KaUcbk8er
    WWdMxDbjt8SdW+fLROBEcwKBgCGQO2SAK3f6bkx4Wsdy5RlXc0a1qgn+HSdMsS4x
    RyPlyWCAhUe1UT38WTkY0qE4Q2w7e0L/1+ZAGmZCvVHAIu7tDVHe65y0bOVrOw9t
    BHCwZmNmDtWNtt7jZIBa3GwVlG258jZAlAlfu3F6l5zWhcqTb9qKbFMurTGNkxdi
    tnRzAoGAVJT6iJKuVQzeq54oKX+yDXkwGqznrRJn3cPoOoxLt8LyQ9+vi+nlegOt
    bDC+Y3++mTxuEBa6rJxKuONLue+cJqXM8aVaidC7aMCvZhXZtjU0MI6XC72tM96C
    xYQKxVQjbOyY3PG4CrQXGfahYkX6ldxET/g3DOwV69XQVNUtL1Y="
    private_key = KeyLoader.load_private_key(private_key_string)
    public_key = KeyLoader.load_public_key(public_key_string)

    encrypted_message = RSACrypto.encrypt_message_public(public_key, message)
    decrypted_message = RSACrypto.decrypt_message_private(private_key, encrypted_message)
    assert(message == decrypted_message)
  end

  describe "Auth.verify_token/1" do
    test "with valid token", %{conn: conn} do
      {token, device_id} = get_jwt_token(conn)
      assert {:ok, device} = Auth.verify_token(token)
      assert device_id == device.device_id
    end

    test "with invalid token" do
      assert :error = Auth.verify_token("")
    end
  end
end
