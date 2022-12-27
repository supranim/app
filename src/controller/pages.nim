import std/[times, json]
import supranim/runtime
import supranim/controller

let currentYear = now().format("yyyy")
proc getHomepage*(req: Request, res: var Response) =
    ## ``GET`` procedure to render the homepage
    res.send Tim.render("index", data = %*{
        "name": "My Supranim",
        "year": $currentYear
    })

proc getAuth*(req: Request, res: var Response) =
    ## ``GET`` procedure to render the homepage
    res.send Tim.render("auth")

proc postAuth*(req: Request, res: var Response) =
    echo req.getFields()
    res.redirect("/")

proc getBlank*(req: Request, res: var Response) =
    res.send ""
