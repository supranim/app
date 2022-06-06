import ../app
import supranim/response

proc homepage*(req: Request, res: Response) =
    ## ``GET`` procedure to render the homepage
    res.response Tim.render("index")