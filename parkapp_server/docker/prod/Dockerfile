FROM ubuntu:latest

ENV LANG=C.UTF-8

WORKDIR /apps

COPY _build/prod/rel/parkapp/releases/0.0.1/parkapp.tar.gz /apps

RUN tar -xzf parkapp.tar.gz && rm parkapp.tar.gz

RUN mkdir priv && mkdir priv/keys

COPY priv/keys/private_test_key.key /apps/priv/keys

RUN apt-get update && apt-get install -y openssl

ENTRYPOINT ["bin/parkapp", "foreground"]
