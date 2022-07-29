import supranim/router
import controller/[pages, err]
import middleware/auth

# A simple GET route
Router.get("/")

# A simple GET route protected by middleware
Router.get("/auth")
Router.post("/auth")

Router.get("/blank")

Router.setErrorPage(HttpCode(404), err.e404)
Router.setErrorPage(HttpCode(404), err.e500)