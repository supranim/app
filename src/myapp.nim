import supranim
import emitter

import ./app

# Application Event Listeners
include ./events/listeners/account

# Initialize application
App.init()

# Start the application server
App.start()