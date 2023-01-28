import controller/[pages, err]

# A simple GET route
Router.get("/")

Router.setErrorPage(HttpCode(404), err.e404)
Router.setErrorPage(HttpCode(500), err.e500)
Router.setErrorPage(HttpCode(503), err.e503)