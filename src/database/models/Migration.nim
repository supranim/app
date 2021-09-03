import times, enimsql

type
    Migration* = ref object of Model
        table*: string
        migrated*: bool
        created*: DateTime
        updated*: DateTime

proc up*[T:User](self: T) =
    ## Procedure for creating the table
    discard

proc down*[T:User](self: T) =
    ## Procedure for dropping the table
    discard