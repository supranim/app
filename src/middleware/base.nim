import std/[strutils, times, options]
import pkg/supranim/middleware
import pkg/limiter

var globalLimiter = Limiter()

newBaseMiddleware limitChecker:
  ## Checks if the request is coming from an IP
  ## address that is currently limited by the server
  if not globalLimiter.hit(req.getIp):
    req.root.resp(code = HttpCode(429), "", res.getHeaders())

newBaseMiddleware uriChecker:
  ## Fix the trailing slash in the URI
  let path = req.getUriPath
  if path != "/" and path[^1] == '/':
    res.addHeader("Location", path[0..^2])
    req.root.resp(code = HttpCode(301), "", res.getHeaders())