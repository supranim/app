from std/strutils import indent, `%`
import supranim/router

Event.listen("system.boot.services") do(services: varargs[Arg]):
    proc refresh() =
        when not defined release:
            {.gcsafe.}: Router.refresh()
    let timTemplates = Tim.precompile do(): refresh()
    echo indent("✓ Tim Templates", 2)
    for k, timTemplate in timTemplates.pairs():
        let count = k + 1
        echo indent("$1. $2" % [$count, timTemplate], 6)