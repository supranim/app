import std/[os, json]

import pkg/supranim/[core/paths, controller]
import ../service/provider/[db, session, tim]

ctrl getHomepage:
  ## renders the home page
  render("index", local = &*{
    "isAuth": false
  })
