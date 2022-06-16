# Package

version       = "0.1.0"
author        = "Supranim"
description   = "Your Supranim Application"
license       = "MIT"
srcDir        = "src"
bin           = @["myapp"]
binDir        = "bin"

after build:
    exec "clear"

task dev, "Development build":
    exec "nimble build --threads:on --gc:arc -d:webapp"

task prod, "Production build":
    exec "nimble build --gc:arc --threads:on -d:release -d:useMalloc --hints:off --opt:speed --spellSuggest -d:webapp"

task up, "Start Application":
    exec "./bin/" & bin[0]

# Dependencies
requires "nim >= 1.4.8"
requires "supranim >= 0.1.0"
requires "limiter >= 0.1.0"
requires "emitter"
requires "tim"