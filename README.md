

[![Build Status](https://travis-ci.org/IngageGroup/Contributr.svg?branch=master)](https://travis-ci.org/IngageGroup/Contributr)


[![Stories in Ready](https://badge.waffle.io/IngageGroup/Contributr.png?label=ready&title=Ready)](https://waffle.io/IngageGroup/Contributr)


# Contributr

This is a simple tool that makes it easy to manage and contribute a bonus to your co-workers. 

# Running the app

## Preqeqs
Reports require wkhtmltopdf. For more detailed info refer to https://github.com/gutschilla/elixir-pdf-generator
Once installed, make sure to change or override the settings to reflect the proper value in config.exs:

config :pdf_generator,
       command_prefix: "/usr/X11/bin/xvfb"


##Starting the app:
  
  * Setup your google account to allow for oauth
    * add environment variables for GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Seed the database with `mix run priv/repo/seeds.exs`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`
  
  
With docker:

  * Edit .env to reflect the correct values
  * docker-compose up -d   

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

