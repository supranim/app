import std/[os, times, sugar, json, sequtils]

import pkg/[bag, jsony, ozark, kapsis/cli]

import pkg/supranim/[core/paths, controller]
import pkg/supranim/support/[auth, nanoid]
import pkg/supranim_session/controller/[login, register, forgot]

import ../service/provider/[db, session, tim, events]

ctrl getAuthLogin:
  ## GET handler renders authentication page
  login.getLogin(getHomepage)

ctrl postAuthLogin:
  ## POST handle authentication requests
  login.postLogin(getHomepage)

ctrl getAuthForgotPassword:
  ## GET handler renders the forgot password page
  forgot.getForgotPassword(getAuthForgotPassword)

ctrl postAuthForgotPassword:
  ## POST handle for forgot password requests
  forgot.postForgotPassword(getAuthForgotPassword)

ctrl getAuthResetPassword:
  ## GET renders the `/auth/reset-password` page
  forgot.getResetPassword(getAuthResetPassword)

ctrl postAuthResetPassword:
  ## POST handle for reset password requests
  forgot.postResetPassword()

ctrl getAuthLogout:
  ## GET handle for logging out.
  ## This will clear the session and redirect to the login page.
  login.getLogout(getAuthLogin)

ctrl getAuthRegister:
  ## GET handle for rendering the registration page
  register.getRegister()

ctrl postAuthRegister:
  ## POST handle for registering a new user
  register.postRegister()

