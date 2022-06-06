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
    exec "nimble build --threads:on --gc:arc"

task up, "Start Application":
    exec "./bin/" & bin[0]

# Dependencies
requires "nim >= 1.4.8"
requires "supranim >= 0.1.0"
requires "limiter >= 0.1.0"
requires "emitter"
# requires "tasks >= 0.1.0"
requires "tim"