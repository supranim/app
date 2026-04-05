import std/[os, times, json, options, sequtils]

import pkg/[bag, ozark, twofa]
import pkg/supranim/[core/paths, controller]
import pkg/supranim/support/auth
import ../service/provider/[db, session, tim]

ctrl getAccount:
  ## Renders the account page with the user's session information.
  ## 
  ## This page allows users to view and manage their account details,
  ## including active sessions and two-factor authentication settings.
  withSession do:
    withDBPool do:
      let
        session = Models.table(UserSessions)
                        .select(["user_id", "created_at", "last_access", "payload"])
                        .where("session_id", userSession.getId())
                        .getAll()
        firstSession = session.first()
        userData = Models.table(Users)
                        .select(["email", "name", "totp_secret"])
                        .where("id", firstSession.getUserId())
                        .getAll().first()
      render("account", local = &*{
        "user": userData,
        "sessions": session.entries,
        "notifications_profile": userSession.getNotifications("/account/profile"),
        "csrf_profile": userSession.genCSRF("/account/profile"),
        "notifications_security": userSession.getNotifications("/account?tab=security"),
        "csrf_security": userSession.genCSRF("/account?tab=security"),
        "security": {
          "totp_qr": twofa.getQR(userData.getTotpSecret())
        }
      })

ctrl postAccountProfile:
  ## POST handle for updating the user profile information
  withSession do:
    let data = req.getFieldsTable.get()
    bag req.getFields:
      name: tText"Invalid name"
      email: tEmail"Invalid password"
      csrf -> callback do(input: string) -> bool:
        userSession.validateCSRF("/account/profile", input)
    do:
      userSession.notify("Could not update profile")
      go getAccount # redirects to `/account`
    
    # update the user profile information in the database
    withDBPool do:
      let currentUser = Models.table(Users)
                        .select(["id", "email"])
                        .where("id", userSession.getUserId().get())
                        .getAll().first()
      if data["email"] != currentUser.getEmail():
        # if the email is being updated, we need to re-verify the email address
        # by generating a new confirmation token and sending a confirmation email
        # to the user with a link to verify their new email address. Until the new email
        # address is verified, the old email address will remain active.
        Models.table(Users).update({
          "name": data["name"],
          "email": data["email"]
        }).where("id", userSession.getUserId().get()).exec()
      else:
        # if the email is not being updated,
        # we can simply update the name
        Models.table(Users).update({
          "name": data["name"]
        }).where("id", userSession.getUserId().get()).exec()
    # once updated we can notify the user and
    # redirect back to the account page
    userSession.notify("Profile updated successfully")
    go getAccount # redirects to `/account`

ctrl postAccountSecurity:
  ## POST handle for updating user security settings
  withSession do:
    let data = req.getFieldsTable.get()
    bag req.getFields:
      current_password: tText"account.password.invalid"
      new_password: tPasswordStrength"account.password_strength"
      csrf -> callback do(input: string) -> bool:
        userSession.validateCSRF("/account/security", input)
    do:
      # if validation fails, 
      for err in inputBag.getErrors:
        userSession.notify(err[1], some("/account?tab=security"))
      go getAccount, [("tab", "security")] # redirects to `/account?tab=security`
    withDBPool do:
      let session = Models.table(UserSessions)
                        .select(["user_id", "created_at", "last_access"])
                        .where("session_id", userSession.getId())
                        .getAll().first()
      let userId = session.getUserId()
      let userData = Models.table(Users)
                        .select(["email", "name", "password"])
                        .where("id", userId)
                        .getAll().first()
      # if the current password provided by the user is incorrect,
      # set the notification and redirect back to the account page
      # with the security tab active.
      if not auth.checkPassword(data["current_password"], userData.getPassword()):
        userSession.notify("Current password is incorrect", some("/account?tab=security"))
        go getAccount, [("tab", "security")] # redirects to `/account?tab=security`
      
      # 
      let newHashedPassword = auth.hashPassword(data["new_password"])
      Models.table(Users).update({
        "password": newHashedPassword
      }).where("id", session.getUserId()).exec()

ctrl getAccountVerify:
  ## GET handle that verifies the user account
  ## by checking the token in the URL. 
  ## 
  ## After verifying the account, we'll generate the 2FA secret 
  ## for the user in case they want to enable 2FA in the future
  withSession do:
    let q {.inject.} = req.getQueryTable()
    if likely(q.hasKey"token"):
      withDBPool do:
        let dbres {.inject.} =
            Models.table(UserAccountConfirmations)
                  .selectAll().where("token", q["token"]).getAll()
        # check if confirmation token is still valid (not expired)
        if not dbres.isEmpty():
          let confirmation {.inject.} = dbres.first()
          let expValue = confirmation.getExpiresAt()
          let expiresAt: DateTime = times.parse(expValue, "yyyy-MM-dd HH:mm:sszz")
          if expiresAt <= now():
            userSession.notify("The confirmation token has expired.", some("/auth/login"))
            go getAccount # redirects to `/account`

          # update the user account to set the is_confirmed field to true
          Models.table(Users).update({
                  "is_confirmed": "true"
                }).where("id",
                  confirmation.getUserId()
                ).exec()
          
          # delete the confirmation token from the database
          Models.table(UserAccountConfirmations)
                .removeRow()
                .where("token", confirmation.getToken).exec()

          # generate the 2FA secret for the freshly verified user account
          # TODO

          # once updated we can notify the user and redirect to the login page.
          userSession.notify("Your account has been verified. You can now login.", some("/auth/login"))
          go getAccount # redirects to `/account`

      # token has expired or is invalid
    userSession.notify("Invalid verification token", some("/auth/login"))
  go getAccount # redirects to `/account`