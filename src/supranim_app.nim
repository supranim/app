import supranim
import emitter

# Include Application Routes
include ./routes
# Include Application Listeners
include ./events/listeners/account

var app = application.init(threads = 1)
app.start()