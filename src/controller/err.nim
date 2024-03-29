import std/[times]
import supranim/runtime

let currentYear = now().format("yyyy")
import std/json

proc e404*(): string =
  result = Tim.render("errors.404", data = %*{
    "name": "My Supranim",
    "year": $currentYear
  })

proc e500*(): string =
  result = Tim.render("errors.500", data = %*{
    "name": "My Supranim",
    "year": $currentYear
  })

proc e503*(): string =
  result = Tim.render("errors.503", data = %*{
    "name": "My Supranim",
    "year": $currentYear
  })

