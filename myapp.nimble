# Package

version       = "0.1.0"
author        = "Supranim"
description   = "Your Supranim Application"
license       = "MIT"
srcDir        = "src"
bin           = @["myapp"]
binDir        = "bin"

# Dependencies
requires "nim >= 1.4.8"
requires "supranim >= 0.1.0"
requires "tim"
requires "limiter"
requires "emitter"
requires "watchout"

task dev, "Development build":
  exec "nimble build --threads:on --gc:arc -d:nimPreviewHashRef -d:enableSup -d:webapp"

task prod, "Production build":
  exec "nimble build --threads:on --gc:arc -d:release -d:nimPreviewHashRef -d:enableSup --hints:off --opt:speed --spellSuggest:0 -d:webapp"

task up, "Start Application":
  exec "./bin/" & bin[0]