# This event listener runs when a 404 error occurs
# in the web application.

import std/options
import supranim/service/events
import pkg/kapsis/interactive/prompts

listener "app.autoload.middleware":
  if args.isSome():
    display(args.get()[0])