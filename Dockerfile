FROM elixir:1.4.4

ENV DEBIAN_FRONTEND=noninteractive
ENV GOOGLE_CLIENT_ID = <SOME_ID>
ENV GOOGLE_CLIENT_SECRET = <SOME_SECRET>

# Install hex
RUN mix local.hex --force

# Install rebar
RUN mix local.rebar --force

# Install the Phoenix framework itself
RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez

# Install NodeJS 6.x and the NPM
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y -q nodejs

# Set /app as workdir
WORKDIR /app
ADD . /app

# Compile and run phoenix. 
RUN mix compile
CMD ["mix", "phoenix.server"]