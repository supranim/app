import ../app

proc e404*(): string =
    result = Tim.render("errors.404")

proc e500*(): string =
    result = Tim.render("errors.404")
