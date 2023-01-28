import std/[times, json]
import supranim/runtime
import supranim/controller

let currentYear = now().format("yyyy")
proc getHomepage*(req: Request, res: var Response): HttpResponse {.cache.} =
    ## ``GET`` procedure to render the homepage
    res.send Tim.render("index", data = %*{
      "title": "My Supranim",
      "year": $currentYear,
      "logo": {
        "src": "https://supranim.com/logo.png",
        "link": "https://supranim.com"
      },
      "boxes": [
        {
          "title": "📚 Documentation",
          "lead": "Whether you are new to the framework or have previous experience with Supranim, we recommend reading all the documentation from begining to end.",
          "button": {
            "link": "https://docs.supranim.com",
            "label": "Check Documentation"
          }
        },
        {
          "title": "💛 Open Source",
          "lead": "Supranim is a free, open-source web framework for web development applications following the model–view–controller architectural pattern",
          "button": {
            "link": "https://supranim.com/donate",
            "label": "Donate for Open Source Development"
          }
        }
      ]
    })

proc getAuth*(req: Request, res: var Response): HttpResponse =
    ## ``GET`` procedure to render the homepage
    res.send Tim.render("auth")

proc postAuth*(req: Request, res: var Response): HttpResponse =
    echo req.getFields()
    res.redirect("/")

proc getBlank*(req: Request, res: var Response): HttpResponse =
    res.send ""
