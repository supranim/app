import supranim/runtime
import supranim/controller

proc getHomepage*(req: Request, res: var Response) =
    ## ``GET`` procedure to render the homepage
    res.send Tim.render("index")

proc getAuth*(req: Request, res: var Response) =
    ## ``GET`` procedure to render the homepage
    res.send readFile("bin/test.html")

proc postAuth*(req: Request, res: var Response) =
    echo req.getFields()
    res.redirect("/")

proc getBlank*(req: Request, res: var Response) =
    res.send ""
