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
    proc reload() =
        when not defined release:
            {.gcsafe.}: Router.refresh()
    let timTemplates = Tim.precompile do(): reload()
    echo indent("✓ Tim Templates", 2)
    for k, timTemplate in timTemplates.pairs():
        let count = k + 1
        echo indent("$1. $2" % [$count, timTemplate], 6)