<p align="center"><img src="/.github/supranim.png" width="180px"><br>
<strong>A simple web framework for creating REST APIs and beautiful web apps. Fully written in Nim</strong>,<br>Supranim is a happy fork of <code>httpbeast</code>, providing extra functionalities, a command line interface, a stupid simple project structure and clean logic.
</p>

**This is a the default application template for creating your next project powered by Supranim.** [Check Supranim repository](https://github.com/supranim/supranim) for more tech details.

# Features
- [x] HTTP/1.1 server
- [x] Multi-threading
- [x] High Performance & Scalability
- [ ] Database `Migrator` / `Schema` / `Model` by **Enismql** and **PostgreSQL**
- [ ] Router with `Group`, `InCacheResponse` and `Middleware` Support
- [ ] `Request` and `Response` handler
- [ ] `Cookie` Jar & `Session` Manager
- [ ] Built-in `CronJob` to kick off jobs at regular intervals
- [ ] Built-in `Auth`
- [ ] Built-in Proxy for routing `Assets` (with middleware support)
- [ ] `i18n` Support
- [ ] `Form` / `Input` Validator
- [ ] `Str` Validator
- [x] Fast & Safe compilation powered by Nim


## Quick Examples
Creating a new Supranim server is easy

```python
from supranim import App, Router, Response, Request, UrlParams

proc AuthMiddleware(): void =
    ## Sample Auth Middleware
    discard

proc homepage(resp: var Response): Response =
    ## A simple procedure for returning a Hello World response
    return resp "Hello World!"

proc aboutUs(resp: var Response): Response =
    ## A simple procedure returning a response for a secondary page
    return resp "This is about us"

proc yourOrder(resp: var Response, req: var Request, params: var UrlParams): Response =
    ## A simple procedure for a route that is middleware-protected,
    ## So, before we call this proc will execute the given middleware.
    ## Also, if provided, it will pass as a 3rd argument an varargs
    ## with available URL parameters
    return resp "Your Order No. #$1" % [ params[0] ]

proc error404(resp: var Response, req: var Request): Response =
    ## A simple procedure for handling 404 errors
    return resp Http404, "404 - Not Found | Sorry, page does not exist"

proc error500(resp: var Response, req: var Request): Response =
    ## A simple procedure for handling 500 errors
    return resp Http404, "500 - Internal Error"


Router.get("/", homepage)
Router.get("/about", aboutUs)
# A route can be protected by providing one or more Middlewares.
# Processing middlewares is done in the order you provide them.
Router.get("/orders/{:id}", yourOrders).middleware(@[AuthMiddleware])

# Routing Assets via Proxy Handler
# Where first parameter must be the relative path to your assets directory,
# and the second one the route for ascessing public files
Router.assets("assets", "media")
# One or more Assets Proxies can be provided to route your assets.
# Let's say we want a route to be available for accessing only by logged in users
Router.assets("private-assets", "private").middleware(@[AuthMiddleware])

# Route your own Error pages
Router.e404(error404)
Router.e500(error500)

App(
    # Server address and port number
    # (Default 127.0.0.1:3399)
    address: "127.0.0.1",
    port: "3399",
    # Boot your app under SSL connection.
    # If set true, it will automatically generate a self-signed
    # SSL certificate (in case it does not exist)
    ssl: true,
    # Enable multi threading support for your Supranim,
    # by allocating one or more from available threads.
    threads: 2,
    # Relative path to your assets directory
    # Used by Assets Proxy Handler for routing
    # your assets to public network
    assets: "../../static"
    # Enable Caching responses of routes registered as GET method
    # Note, Works only for routes with no Middleware attached
    # and with callback procedure that have return type of 'string'
    rcache: true
).run()

```
