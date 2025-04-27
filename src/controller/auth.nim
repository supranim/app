import std/[os, times, sugar, json, sequtils]
import pkg/[bag, jsony, enimsql, kapsis/cli]
import pkg/supranim/[core/paths, controller]
import pkg/supranim/support/auth

import ../service/singleton/[db, session, tim, events]

ctrl getAuthLogin:
  ## renders authentication page
  withSession do:
    if userSession.isAuthenticated():
      # if the user is already authenticated
      # redirect to the account page
      go getAccount
    else:
      render("auth.login", local = &*{
        "notifications": userSession.getNotifications(req.getUriPath).get(@[]),
        "csrf": userSession.genCSRF("/auth/login")
      })

let authErrorMessage = "Invalid email address or password"
ctrl postAuthLogin:
  ## handle authentication requests
  withSession do:
    if userSession.isAuthenticated():
      # if the user is already authenticated
      # redirect to the account page
      go getAccount # redirects to `/account`

    # validates the request fields
    # if the email address is not valid, notify the user
    # using a specific error message, otherwise use the
    # default error message and redirect to `/auth/login`
    bag req.getFields:
      email: tEmail""
      password: tPassword""
      csrf -> callback do(input: string) -> bool:
        # validate the CSRF token required for authentication
        return userSession.validateCSRF("/auth/login", input)
    do:
      userSession.notify(authErrorMessage)
      go getAccount # redirects to `/account`

    withDB do:
      let collection =
        Models.table("users").select
              .where("email", req.getFields[0][1]).get()
      if unlikely(collection.isEmpty):
        userSession.notify(authErrorMessage)
        go getAccount

      let user = collection.first()
      if auth.checkPassword(req.getFields[1][1], user.get("password").value):
        if likely(user.get("is_confirmed").value == "t"):
          # Checks if the user account is confirmed before
          # authenticating the user. set payload with user data
          userSession.updatePayload(req.getClientData())

          # store the authenticated user session in the database
          Models.table("user_sessions").insert({
            "user_id": user.get("id").value,
            "session_id": userSession.getId(),
            "payload": toJson(userSession.getPayload()),
            "created_at": $(userSession.getCreatedAt())
          }).exec()
        else:
          # if the user is not confirmed, notify the user
          # and redirect to `/auth/login`
          userSession.notify("Your account is not confirmed. Check your email inbox or spam folder.")
          go getAccount # redirects to `/account`
    
    # authentication failed, we'll use the same
    # error message to prevent email enumeration attacks
    userSession.notify(authErrorMessage)
  go getAccount # redirects to `/account`

ctrl getAuthForgotPassword:
  ## renders the forgot password page
  if unlikely(isAuth()):
    # already loggedin, redirect to `getAccount`
    go getAccount
  withSession do:
    render("auth.forgot", local = &*{
      "notifications": userSession.getNotifications(req.getUriPath).get(@[]),
      "csrf": userSession.genCSRF("/auth/forgot-password")
    })

const forgotPasswordSubmitMessage =
  "A reset password link has been sent to your email address. Check your inbox or spam folder."

ctrl postAuthForgotPassword:
  ## Handle forgot password requests.
  withUserSession do:
    if unlikely(isAuth()):
      # already loggedin, redirect to `/account`
      go getAccount

    bag req.getFields:
      # default error message for invalid emails
      email: tEmail"Email address is not valid"
      csrf -> callback do(input: string) -> bool:
        # validate the CSRF token required for resetting the password
        return userSession.validateCSRF("/auth/forgot-password", input)
    do:
      # if the email address is not valid, notify the user
      # and redirect to `/auth/forgot-password`
      let invalidEmailMsg = inputBag.getErrors.toSeq()[0][1]
      userSession.notify(invalidEmailMsg)
      go getAuthForgotPassword # redirects to `/auth/forgot-password`

    # emit `account.request.reset` event to handle the
    # password reset request. this event is spawned in a new thread
    # to avoid blocking the request.
    events.emitter("account.password.request", some(@[req.getFields[0][1]]))

    # notify the user that a reset password link has been
    # sent to the given email address. Same message is used
    # even if the email address is not registered in the database
    # (to prevent email enumeration attacks).
    userSession.notify(forgotPasswordSubmitMessage)

  # redirects to `/auth/forgot-password`
  go getAuthForgotPassword

ctrl getAuthResetPassword:
  ## renders the `/auth/reset-password` page
  if unlikely(isAuth()):
    # already loggedin, redirect to `getAccount`
    go getAccount
  withSession do:
    let query = req.getQueryTable()
    if query.hasKey("token"):
      let reqToken = query["token"]
      withDB do:
        let passRequestRes =
              Models.table("user_account_password_resets")
                    .select.where("token", reqToken)
                    .get()
        if unlikely(passRequestRes.isEmpty):
          # if requested token is not found in the database
          # notify the user and redirect to `/auth/forgot-password`
          userSession.notify("Invalid reset password link", some("/auth/forgot-password"))
          go getAuthForgotPassword
        else:
          let
            expValue = passRequestRes.first().get("expires_at").value
            expiresAt: DateTime = times.parse(expValue, "yyyy-MM-dd HH:mm:sszz")
          # check if the token is expired if the token is
          # expired, notify the user and redirect to `/auth/forgot-password`
          if now() >= expiresAt:
            userSession.notify("The link has expired. Please, request a new one.", some("/auth/forgot-password"))
            go getAuthForgotPassword # redirects to `/auth/forgot-password`

      render("auth.reset", local = &*{
        "resetToken": reqToken,
        "notifications": userSession.getNotifications(req.getUriPath).get(@[]),
        "csrf": userSession.genCSRF("/auth/reset-password")
      })
    else:
      # if the token is not present in the query string,
      # redirect to `/auth/login`
      userSession.notify("Invalid reset password link", some("/auth/forgot-password"))
      go getAuthForgotPassword # redirects to `/auth/forgot-password`

ctrl postAuthResetPassword:
  ## POST handle for reset password requests
  let q = req.getFieldsTable().get()
  withSession do:
    withValidator req.getFields:
      new_password: tPasswordStrength""
        # a strong password is required
      new_password_confirm -> callback do(input: string) -> bool:
        # ensure the password matches the confirmation password
        q["new_password_confirm"] == q.getOrDefault"new_password"
      token -> callback do(input: string) -> bool:
        # validate the token required for resetting the password
        return true
      csrf -> callback do(input: string) -> bool:
        # validate the CSRF token required for resetting the password
        return userSession.validateCSRF("/auth/reset-password", input)
    do:
      var hasValidToken: bool
      let fields = inputBag.getErrors.toSeq().mapIt(it[0])
      echo fields.contains("token")
      hasValidToken = fields.contains("token") == false
      if hasValidToken:
        # set the flash message to notify the user
        # that the password is not strong enough
        # and redirect to `/auth/reset-password`
        userSession.notify("The entered password is not strong enough")
        go getAuthResetPassword, @[("token", q["token"])]
      else:
        go getAuthForgotPassword # redirects to `/auth/forgot-password`
    
    # when staticConfig("session.authentication.reset_password.require_same_device"):
      # when enabled, it will only allow
      # password reset requests from the same device used
      # to request the password reset.
      # this is useful to prevent password reset 
    withDB do:
      let tokenRes = Models.table("user_account_password_resets")
                          .select.where("token", q["token"]).get()
      if not tokenRes.isEmpty:
        let
          token = tokenRes.first()
          expValue = token.get("expires_at").value
          expiresAt: DateTime = times.parse(expValue, "yyyy-MM-dd HH:mm:sszz")

        if now() >= expiresAt:
          # if token has expried, will  notify the user
          # and redirect to `/auth/forgot-password`
          userSession.notify("The link has expired. Please, request a new one.", some("/auth/forgot-password"))
          go getAuthForgotPassword # redirects to `/auth/forgot-password`

        # update the password in the database
        Models.table("users").update("password", auth.hashPassword(q["new_password"]))
                             .where("id", token.get("user_id").value).exec()

        # delete the password reset token from the database
        assert Models.table("user_account_password_resets")
                     .remove.where("token", q["token"]).execGet() == 1

        # update the password in the database
        userSession.notify("Password has been updated", some("/auth/login"))

  # redirects to `/auth/login`
  go getAuthLogin

ctrl getAuthLogout:
  ## GET handle to destroy user sessions
  withSession do:
    if userSession.isAuthenticated():
      # we neeed an authenticated user session
      # to perform the logout
      withDB do:
        # delete the user session from the database
        assert Models.table("user_sessions").remove
                         .where("session_id", userSession.getId())
                         .execGet() == 1
      # update client cookie with the new expiration
      # date so browser can invalidate the session
      userSession.destroy(res)

  # redirects to `/auth/login`
  go getAuthLogin

ctrl getAuthRegister:
  ## GET handle for rendering the registration page
  withSession do:
    render("auth.register", local = &*{
      "notifications": userSession.getNotifications(req.getUriPath).get(@[]),
      "csrf": userSession.genCSRF("/auth/register")
    })

const registrationMessage = "Thansk for registration! If this is a new account, a confirmation link will be sent to your email address. If you lost access to your account, <a href='/auth/forgot-password'>reset your password here</a>."
ctrl postAuthRegister:
  ## POST handle for registering a new user
  let q = req.getFieldsTable().get()
  withSession do:
    withValidator req.getFields:
      email: tEmail""
      password: tPasswordStrength""
        # a strong password is required
      password_confirm -> callback do(input: string) -> bool:
        # ensure the password matches the confirmation password
        q["password_confirm"] == q.getOrDefault"password"
    do:
      # validation failed, set the flash message to notify
      # the user and redirect back to `/auth/register`
      let fields = inputBag.getErrors.toSeq().mapIt(it[0])
      if fields.contains("email"):
        userSession.notify("The email address is not valid")
      elif fields.contains("password"):
        userSession.notify("The password is not strong enough")
      elif fields.contains("password_confirm"):
        userSession.notify("The password confirmation does not match")
      else:
        userSession.notify(registrationMessage)
      go getAuthRegister # get redirected to `/auth/register`


    # emit `account.register` event to handle the
    # registration request. this event is spawned in a new thread
    # to avoid blocking the request.
    events.emitter("account.register", some(@[req.getFields[0][1], req.getFields[1][1]]))
    
    # notify the user that the account has been created
    # and a confirmation link has been sent to the given email address.
    userSession.notify(registrationMessage, some("/auth/login"))
    
    # redirect to `/auth/login`
    go getAuthLogin
