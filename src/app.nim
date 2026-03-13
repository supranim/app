#
# This is the main file for the Supranim application.
#
# It initializes the application, loads configurations,
# and sets up the necessary services and middlewares.
#
import std/times
import pkg/supranim

#
# Init core modules using `init` macro
#
App.init()

proc startCommand(v: Values) =
  ## Kapsis `init` command handler
  initStartCommand(v, createDirs = false)

App.cli do:
  start path(directory):
    ## Init the app with the given installation path

#
# Initialize available Service Providers.
#
# Configuration files are defined as YAML in the
# `config/` directory.
#
App.services do:

  # Initialize the global event emitter service. This service provides a
  # singleton event emitter that can be used throughout the application to
  # emit and listen for custom events.
  events.init()

  # init DB Engine
  db.init()

  # init Tim Engine
  tim.init(
    App.config("tim.source").getStr,
    App.config("tim.output").getStr,
    supranim.basePath,
    global = %*{
      "system": {
        "isDevelopment": (
          when not defined(release): true
          else: false
        )
      },
      "date": {
        "year": now().year
      },
      "homepage_cover": "/assets/photo-1579169703977-e4575236583c.jpeg",
      "login_cover": "https://images.unsplash.com/flagged/photo-1562061162-254644341e89?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
    }
  )

  # initialize your service providers here

#
# Starts the application. This will start the HTTP
# server and listen for incoming requests.
#
# The application will be available at the specified port.
#
App.run()