import std/[times, json]
import supranim/runtime

let currentYear = now().format("yyyy")

proc e404*(): string =
    result = Tim.render("errors.404", data = %*{
        "name": "My Supranim",
        "year": $currentYear
    })

proc e500*(): string =
    result = Tim.render("errors.404", data = %*{
        "name": "My Supranim",
        "year": $currentYear
    })
