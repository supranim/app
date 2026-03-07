import std/[strutils, tables, times, macros, os]
import pkg/[ozark, jsony, kapsis/cli]

import pkg/supranim/core/servicemanager
import pkg/supranim/core/[paths, config]
import pkg/supranim/support/[nanoid, auth, url]

initService DB[Global]:
  backend do:
    macro loadModels =
      # auto discover /database/models/*.nim
      # nim files prefixed with `!` will be ignored
      result = newStmtList()
      for fModel in walkDirRec(modelPath):
        let f = fModel.splitFile
        if f.ext == ".nim" and f.name.startsWith("!") == false:
          add result, nnkImportStmt.newTree(newLit(fModel))
          add result, nnkExportStmt.newTree(ident(f.name))
    loadModels() # autoload available models

  client do:
    proc init*() =
      loadEnvStatic()
      ozark.initOzarkDatabase(
        address = getEnv("database.address"),
        name = getEnv("database.name"),
        user = getEnv("database.user"),
        password = getEnv("database.password")
      )
      initOzarkPool(10)
      try:
        withDBPool do:
          # create database tables if not exists
          Models.table(Users).prepareTable().exec()
          Models.table(UserSessions).prepareTable().exec()
          Models.table(UserAccountConfirmations).prepareTable().exec()
          Models.table(UserAccountEmailConfirmations).prepareTable().exec()
          Models.table(UserAccountPasswordResets).prepareTable().exec()

          # the following code is used to create a test user account.
          # this code should be removed in production
          # and should be moved to a seeder or a migration file.
          let userRes = Models.table(Users)
                              .selectAll().where("id", "1").getAll()

          if userRes.isEmpty:
            let (pk, sk) = auth.boxKeys()
            let userId = Models.table(Users).insert({
              "name": "Johnny Dope",
              "username": nanoid.generate(size = 32),
              "email": "test@example.com",
              "pk": pk,
              "sk": sk,
              "password": auth.hashPassword("strong password here"),
              "created_at": $(now())
            }).execGet()
            
            displaySuccess("Created test account:")
            display(span("E-mail:"), green("test@example.com"))
            display(span("Password:"), green("strong password here"), span("\n"))

            let confirmationLink = auth.boxEncrypt("test@example.com", pk, sk)
            Models.table(UserAccountConfirmations).insert({
              "user_id": $userId,
              "token": confirmationLink,
              "created_at": $(now()),
              "expires_at": $(now() + 10.minutes)
            }).exec()
            displayInfo("Confirmation link:")
            display($link("/account/verify", {"token": confirmationLink}))
      except DbError:
        displayError("Database connection failed. Please check your database settings.")