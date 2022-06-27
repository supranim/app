import ../app
import supranim/response

proc getHomepage*(req: Request, res: Response) =
    ## ``GET`` procedure to render the homepage
    res.response Tim.render("index")

proc getAccount*(req: Request, res: Response) =
    ## ``GET`` procedure to render the homepage
    res.response Tim.render("index")

proc getAuth*(req: Request, res: Response) =
    res.response Tim.render("auth")
