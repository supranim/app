import supranim
include ./routes

var app = Application.init(threads = 2)
app.start()