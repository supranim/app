import supranim
import ./app
include ./events/listeners/system

import macros

type
    ConfigType* = enum
        None, System, Package

    AppConfig* = object of RootObj
        ## Used to create configuration files for your Supranim applications.
        ## Do not use this object directly, instead use `newConfig` macro
        ## to generate configurations for your app.
        config_id: string
            ## Name of the configuration file
        case owner_type: ConfigType
            ## The name of the package that created the config
            ## otherwise is part of the System
        of System:
            system_id: string
        of Package:
            package_id: string
        else: discard

macro newConfig*(configName: static string, configs: untyped) =
    ## Create a new configuration file at compile-time.
    result = newStmtList()
    # nnkTypeSection.newTree(
    #     nnkTypeDef.newTree(
    #         nnkPostfix.newTree(
    #             newIdentNode("*"),
    #             newIdentNode("Test")
    #         ),
    #         newEmptyNode(),
    #         nnkRefTy.newTree(
    #             nnkObjectTy.newTree(
    #                 newEmptyNode(),
    #                 nnkOfInherit.newTree(
    #                     newIdentNode("AppConfig")
    #                 ),
    #                 reclists
    #             )
    #         )
    #     )
    # )
    var fields = newTree(nnkRecList)
    for config in configs:
        config[0].expectKind nnkIdent
        let fieldIdent = config[0].strVal
        if config[1].kind in {nnkStrLit, nnkIntLit, nnkCharLit}:
            echo config[1].kind
            # fields.add(
            #     nnkIdentDefs.newTree(
            #         ident fieldIdent,
            #         ident 
            #     )
            # )
        elif config[1].kind == nnkPrefix:
            echo config[1][0].kind
        # fields.add(
        #     nnkIdentDefs.newTree(
        #         newIdentNode("name"),
        #         newIdentNode("string"),
        #         newEmptyNode()
        #     ),
        # )
            # nnkIdentDefs.newTree(
            #     newIdentNode("ola"),
            #     nnkTupleTy.newTree(
            #         nnkIdentDefs.newTree(
            #             newIdentNode("ok"),
            #             newIdentNode("string"),
            #             newEmptyNode()
            #         ),
            #         nnkIdentDefs.newTree(
            #             newIdentNode("ok2"),
            #             newIdentNode("int"),
            #             newEmptyNode()
            #         )
            #     ),
            #     newEmptyNode()
            # )
        # )
        # echo config[0].kind
    # let appConfig = configs.symbol.getImpl
    # result.add quote do:
    #     echo `appConfig`

# include ./configs/app

# Initialize application
App.init()


# Start the application server
App.start()