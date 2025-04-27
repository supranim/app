import pkg/supranim/model

#
# users
#
newModel Users:
  # This model is used to store the
  # user data for the application.
  id {.pk.}: Serial
  username {.unique, notnull.}: Varchar(255)
  name: Varchar(255)
  email {.unique, notnull.}: Varchar(255)
  password {.notnull.}: Text
  pk {.notnull.}: Text
  sk {.notnull.}: Text
  is_confirmed {.notnull.}: Boolean = false
  custom_fields: Jsonb
  created_at: TimestampTz
  updated_at: TimestampTz

#
# user_account_confirmations
#
newModel UserAccountConfirmations:
  # This model is used to store the
  # account confirmation tokens for new registred users.
  user_id {.notnull.}: Users.id
  token {.notnull.}: Text
  created_at {.notnull.}: TimestampTz
  expires_at {.notnull.}: TimestampTz

#
# user_account_email_confirmations
#
newModel UserAccountEmailConfirmations:
  # This model is used to store new email
  # addresses and their confirmation tokens.
  user_id {.notnull.}: Users.id
  email {.notnull.}: Varchar(255)
  token {.notnull.}: Text
  created_at {.notnull.}: TimestampTz
  expires_at {.notnull.}: TimestampTz

#
# user_account_password_resets
#
newModel UserAccountPasswordResets:
  # This model is used to store the
  # password reset tokens for users.
  user_id {.notnull.}: Users.id
  token {.notnull.}: Text
  created_at {.notnull.}: TimestampTz
  expires_at {.notnull.}: TimestampTz

#
# user_sessions
#
newModel UserSessions:
  # This model is used to store the
  # user sessions for the application.
  user_id {.notnull.}: Users.id
  session_id {.notnull.}: Varchar(255)
  payload {.notnull.}: JSON
  created_at {.notnull.}: TimestampTz
  # expires_at {.notnull.}: TimestampTz