#
# This file is automatically imported by the Supranim framework.
# It is used to define the routes for the application.
#

routes:
  get "/"
    # GET route links to `getHomepage` controller

  get "/account" {.middleware: [authenticate].}
    # GET route links to `getAccount` controller

  get "/account/verify"
    # GET route links to `getAccountVerify` controller

  get "/auth/login"
    # GET route links to `getAuthLogin` controller

  post "/auth/login"
    # POST route links to `postAuthLogin` controller

  get[post] "/auth/register"
    # GET & POST route links to `getRegister` & `postRegister` controllers

  get "/auth/forgot-password"
    # GET route links to `getForgotPassword` controller
  
  post "/auth/forgot-password"
    # POST route links to `postForgotPassword` controller
  
  get "/auth/reset-password"
    # GET route links to `getResetPassword` controller

  post "/auth/reset-password"
    # POST route links to `postResetPassword` controller

  get "/auth/logout"
    # GET route links to `getLogout` controller