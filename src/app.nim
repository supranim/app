import supranim
include ./routes

Application(
    # Server address and port number
    # (Default 127.0.0.1:3399)
    address: "127.0.0.1",
    port: 3399.Port,
    # Boot your app under SSL connection.
    # If set true, it will automatically generate a self-signed
    # SSL certificate (in case it does not exist)
    ssl: true,
    # Enable multi threading support for your Supranim,
    # by allocating one or more from available threads.
    threads: 2,
    # Relative path to your assets directory
    # Used by Assets Proxy Handler for routing
    # your assets to public network
    assets: "static"
).start()