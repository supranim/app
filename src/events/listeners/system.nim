from std/strutils import indent, `%`

Event.listen("system.boot.services") do(services: varargs[Arg]):
    let timTemplates = Tim.precompile()
    echo indent("✓ Tim Templates", 2)
    for k, timTemplate in timTemplates.pairs():
        let count = k + 1
        echo indent("$1. $2" % [$count, timTemplate], 6)