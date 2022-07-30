import supranim
import ./app

# TODO autoload available event listeners
include ./events/listeners/system

# Initialize application
App.init()

# Start the application server
App.start()