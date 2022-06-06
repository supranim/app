import supranim
import emitter

import ./app

# Application routes
include ./routes

# Application Event Listeners
include ./events/listeners/account

# Precompile app templates with Tim Engine
Tim.precompile()

# Setup your application
var server = application.init(threads = 1)

# Start
server.start()