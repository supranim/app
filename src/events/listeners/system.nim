from std/strutils import indent, `%`
import supranim/router

Event.listen("system.http.501") do(callback: varargs[Arg]):
  discard

Event.listen("system.http.404") do(callback: varargs[Arg]):
  discard

Event.listen("system.http.middleware.redirect") do(callback: varargs[Arg]):
  discard

Event.listen("system.http.assets.404") do(callback: varargs[Arg]):
  discard

Event.listen("system.boot.services") do(services: varargs[Arg]):
  when not defined release:
    proc reload() =
      {.gcsafe.}: Router.refresh()
    Tim.precompile do(): reload()
  else: Tim.precompile()