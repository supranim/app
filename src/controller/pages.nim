import ../app
import supranim/response

proc getHomepage*(req: Request, res: var Response) =
    ## ``GET`` procedure to render the homepage
    res.response Tim.render("index")

proc getAccount*(req: Request, res: var Response) =
    ## ``GET`` procedure to render the homepage
    res.response Tim.render("index")

proc getBlank*(req: Request, res: var Response) =
    res.response ""
