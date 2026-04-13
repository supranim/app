#
# This file is automatically imported by the Supranim framework.
# It is used to define the routes for the application.
#

routes:
  get "/"
    # GET route links to `getHomepage` controller

  get "/account" {.middleware: [authenticate].}
    # GET route links to `getAccount` controller
  
  post "/account/profile" {.middleware: [authenticate].}
    # POST route links to `postAccountProfile` controller

  post "/account/security" {.middleware: [authenticate].}
    # POST route links to `postAccountSecurity` controller

  get "/account/verify"
    # GET route links to `getAccountVerify` controller

  # Group routes under the `/auth` path for
  # authentication-related pages and actions
  group "/auth":
    (get, post) -> "/login"
      # GET and POST routes link to `getAuthLogin` and `postAuthLogin`
      # controllers respectively
    
    (get, post) -> "/forgot-password"
      # GET and POST routes link to `getAuthForgotPassword` and
      # `postAuthForgotPassword` controllers respectively
    
    (get, post) -> "/reset-password"
      # GET and POST routes link to `getAuthResetPassword` and
      # `postAuthResetPassword` controllers respectively
    
    (get, post) -> "/register"
      # GET and POST routes link to `getAuthRegister` and
      # `postAuthRegister` controllers respectively

    get "/logout"
      # GET route links to `getAuthLogout` controller
