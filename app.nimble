# Package

version       = "0.1.0"
author        = "George Lemon"
description   = "A new awesome Supranim application"
license       = "MIT"
srcDir        = "src"
bin           = @["app"]
binDir        = "build"


# Dependencies

requires "nim >= 2.0.0"
requires "supranim#head"
requires "tim#head"
requires "limiter#head"
requires "bag"
requires "jsony"
requires "zippy"
requires "supranim_session"
requires "enimsql#head"

# requires "htmlparser"
requires "libffi"

task dev, "Generate a development build":
  exec "nimble build"

task prod, "Generate a production build":
  exec "nimble build -d:release"

import std/[os, strutils]
task services, "Build all services":
  # Discover and build all service providers
  for src in walkDir("./src/service"):
    let file = splitFile(src.path)
    if file.ext == ".nim":
      exec "nimble c --opt:speed -d:useMalloc --path: --mm:arc --out:./bin/" & bin[0] & "_" & file.name & " " & src.path

task service, "Build a Supranim Service":
  # Build a specific service by name
  let params = commandLineParams()
  exec "nimble c --opt:speed -d:useMalloc --path: --mm:arc --out:./bin/" & bin[0] & "_" & params[^1] & " ./src/service/" & params[^1] & ".nim"