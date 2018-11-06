FROM elixir:1.7.3

WORKDIR /apps

RUN apt-get update && apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -

RUN apt-get update && apt-get install -y nodejs python python-pip python-dev openssl ghostscript

RUN pip install awscli && pip install --upgrade pip
