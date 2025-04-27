import std/[os, json]

import pkg/[bag, enimsql]
import pkg/supranim/[core/paths, controller]
import ../service/singleton/[db, session, tim]

ctrl getHomepage:
  ## renders the home page
  withDB:
    let res = Models.table("users").select.where("id", "1").get()
  render("index", local = &*{})