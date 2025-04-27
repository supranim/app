import pkg/enimsql
import pkg/supranim/middleware
import ../service/singleton/session

newMiddleware authenticate:
  ## Middleware that checks if the user is authenticated.
  ## Redirects to the login page if not
  withUserSession do:
    let userData = %*{
      "ip": req.getIp(),
      "platform": req.getPlatform().get(),
      "agent": req.getAgent().get(),
      "sec-ch-ua": req.getBrowserName().get()
    }
    if userSession.isAuthenticated():
      next() # continue to the next middleware

  abort("/auth/login") # redirects to `GET /auth/login` page
