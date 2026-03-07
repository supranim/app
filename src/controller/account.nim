import std/[os, times, json, options]

import pkg/[bag, ozark]
import pkg/supranim/[core/paths, controller]
import ../service/provider/[db, session, tim]

ctrl getAccount:
  ## Renders the account page
  # withDBPool:
    # let res = Models.table("users").select.where("id", "1").getAll()
  # echo toJson(session.getData(req.getClientID.get()))
  render("account", local = &*{})

ctrl getAccountVerify:
  ## GET handle that verifies the user account
  ## by checking the token in the URL
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

          # once updated we can notify the user and redirect to the login page.
          userSession.notify("Your account has been verified. You can now login.", some("/auth/login"))
          go getAccount # redirects to `/account`

      # token has expired or is invalid
    userSession.notify("Invalid verification token", some("/auth/login"))
  go getAccount # redirects to `/account`