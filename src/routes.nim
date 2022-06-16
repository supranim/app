import supranim/router
import controller/[pages, err]
import middleware/auth

# A simple GET route
Router.get("/")

# A simple GET route with `authentication` middleware
Router.get("/profile").middleware(authentication)

Router.setErrorPage(HttpCode(404), err.e404)
Router.setErrorPage(HttpCode(404), err.e500)