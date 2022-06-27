import supranim/middleware

proc authentication*(res: var Response): bool =
    result = false
    if result:
        redirects("/account")
    else:
        redirects("/auth")