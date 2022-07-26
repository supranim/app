import tim, emitter
import supranim/response

export response
export tim.precompile, tim.render, tim.getLayouts, tim.getFilePath
export emitter

var Tim* = TimEngine.init(
    "./templates",
    "./storage/templates",
    minified = true,
    indent = 4,
    reloader = HttpReloader
)

Event.init()