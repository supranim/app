import times, enimsql
import ./role

type
    User* = ref object of Model
        name*: string
        email*: string
        password* string
        phone*: string
        address*: string
        confirmed*: bool
        role*: Role
        created*: DateTime
        updated*: DateTime

proc up*[T:User](self: T) =
    ## Procedure for creating the table
    discard

proc down*[T:User](self: T) =
    ## Procedure for dropping the table
    discard