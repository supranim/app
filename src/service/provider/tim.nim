import std/[macros, critbits, json, os,
        strutils, sequtils, httpcore, strtabs, times]

import pkg/supranim/[core/paths, support/slug]
import pkg/supranim/core/servicemanager

import pkg/[tim, kapsis/cli]

export HttpCode, render, `&*`
export times.now, times.format

initService Tim[Global]:
  # A singleton service that wraps the Tim Engine
  # and provides a simple interface to render HTML pages
  backend do:
    var timInstance: TimEngine
    proc init*(src, output, basePath: string; global = newJObject()) =
      ## Initialize Tim Engine as a singleton service
      timInstance = newTim(
        src = src,
        output = output,
        basePath = basePath,
        globalData = global
      )

      # predefine foreign functions
      timInstance.userScript.addProc("slugify", @[paramDef("s", ttyString)], ttyString,
        proc (args: StackView): Value =
          ## Convert a string to a URL-friendly slug
          return initValue(slugify(args[0].stringVal[]))
        )

      timInstance.userScript.addProc("dashboard", @[paramDef("x", ttyString)], ttyString,
        proc (args: StackView): Value =
          # prefix a link with `/dashboard/`
          return initValue("/dashboard/" & args[0].stringVal[])
        )
      
      # Initialize common storage with request-specific data
      # this allows templates to access these values via `$this` without needing
      # to pass them explicitly every time, such as the current URL, year,
      # and authentication status
      tim.initCommonStorage:
        {
          "path": req.getUrl(),
          "currentYear": now().format("yyyy"),
          "isAuth": req.isAuthenticated(res)
        }

      timInstance.precompile()

    proc getTimInstance*: TimEngine =
      # Returns the singleton instance of the Tim Engine
      if timInstance == nil:
        raise newException(ValueError, "Tim Engine not initialized")
      return timInstance

  client do:
    template render*(view: string, layout: string = "base",
                      httpCode = Http200, local: JsonNode = nil): untyped =
      ## Renders a Tim template and sends it as an HTTP response.
      ## It must be used within a route handler (controller).
      try:
        let output = render(timInstance, view, layout, local)
        respond(httpCode, output)
      except:
        let errMsg = getCurrentExceptionMsg()
        displayError("<runtime.exception> " & errMsg)
        try:
          let errorLocal = %*{"error": errMsg}
          respond(Http500, render(timInstance, "errors.5xx", layout, errorLocal))
        except:
          respond(Http500, "Internal Server Error: " & errMsg)