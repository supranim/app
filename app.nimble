# Package

# version       = "0.1.0"
# author        = "$supraAuthorNimble"
# description   = "A new awesome Supranim application"
# license       = "$supraAuthorLicense"
# srcDir        = "src"
# bin           = @["$supraBinName"]
# binDir        = "build"
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
requires "supranim_session"
requires "limiter#head"
requires "emitter#head"
requires "bag"
requires "tim#head"
requires "jsony"
requires "zippy"
requires "twofa"

task prod, "Generate a production build":
  # A production build task that compiles the main application
  # and all services with optimizations and release settings.
  exec "nimble build -d:release"

import std/[os, strutils]
task services, "Build all services":
  # Automatically build all services in the src/service directory
  # This task walks through the src/service directory, finds all Nim files,
  # and compiles them into the bin directory with appropriate naming.
  for src in walkDir("./src/service"):
    let file = splitFile(src.path)
    if file.ext == ".nim":
      exec "nimble c --opt:speed -d:useMalloc --path: --mm:arc --out:./bin/" & bin[0] & "_" & file.name & " " & src.path

task service, "Build a Supranim Service":
  # A task to build a specific service by name.
  # Usage: `nimble service <serviceName>`
  let params = commandLineParams()
  exec "nimble c --opt:speed -d:useMalloc --path: --mm:arc --out:./bin/" & bin[0] & "_" & params[^1] & " ./src/service/" & params[^1] & ".nim"