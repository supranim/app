import std/[os, times, json, options]

import pkg/[bag, enimsql]
import pkg/supranim/[core/paths, controller]

import ../service/singleton/[db, session, tim]

ctrl getAccount:
  ## Renders the account page
  # withDB:
    # let res = Models.table("users").select.where("id", "1").get()
  # echo toJson(session.getData(req.getClientID.get()))
  render("account", local = &*{})

ctrl getAccountVerify:
  ## GET handle that verifies the user account
  ## by checking the token in the URL
  let q = req.getQueryTable()
  withSession do:
    if likely(q.hasKey"token"):
      withDB do:
        let dbres =
            Models.table("user_account_confirmations")
                  .select.where("token", q["token"]).get()
        # check if confirmation token is still valid (not expired)
        if not dbres.isEmpty():
          let
            confirmation = dbres.first()
            expValue = confirmation.get("expires_at").value
            expiresAt: DateTime = times.parse(expValue, "yyyy-MM-dd HH:mm:sszz")
          
          if expiresAt <= now():
            userSession.notify("The confirmation token has expired.", some("/auth/login"))
            go getAccount # redirects to `/account`

          # update the user account to set the is_confirmed field to true
          let user_id = confirmation.get("user_id").value
          Models.table("users").update("is_confirmed", "true")
                               .where("id", user_id).exec()  

          # delete the confirmation token from the database
          assert Models.table("user_account_confirmations")
                       .remove.where("token", q["token"]).execGet() == 1

          # once updated we can notify the user and redirect to the login page.
          userSession.notify("Your account has been verified. You can now login.", some("/auth/login"))
          go getAccount # redirects to `/account`

      # token has expired or is invalid
    userSession.notify("Invalid verification token", some("/auth/login"))
  go getAccount # redirects to `/account`