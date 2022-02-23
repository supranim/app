# Package

version       = "0.1.0"
author        = "Supranim"
description   = "Your Supranim Application"
license       = "MIT"
srcDir        = "src"
bin           = @["supranim_app"]
binDir        = "bin"

# requires "tim"


# Supranim Tasks
# https://nim-lang.org/docs/nims.html

after build:
    exec "clear"

task service, "builds an example":
    echo "service"

task dev, "Development build":
    exec "nimble build --threads:on --gc:arc"

task up, "Start Application":
    exec "./bin/supranim_app"

# Dependencies
requires "nim >= 1.4.8"
requires "supranim >= 0.1.0"