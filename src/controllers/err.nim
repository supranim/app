from supranim import Response, Request

proc e404*(resp: var Response, req: var Request): Response =
    ## A simple procedure for handling 404 responses
    return resp Http404, "404 - Not Found | Sorry, page does not exist"

proc e500*(resp: var Response, req: var Request): Response =
    ## A simple procedure for handling 500 responses
    return resp Http500, "500 - Internal Error"
