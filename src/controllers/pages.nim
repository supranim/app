from supranim import Request, send
# import supranim/session/cookiejar

proc homepage*(req: Request) =
    ## A simple procedure for returning a Hello World response
    # cookiejar.addCookie("test", "aha")
    # echo $cookiejar.hasCookie("test")
    req.send("Yeyeye thats good")