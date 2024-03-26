# This is just an example to get you started. Users of your hybrid library will
# import this file by writing ``import gridtppkg/submodule``. Feel free to rename or
# remove this file altogether. You may create additional modules alongside
# this file as required.

proc getWelcomeMessage*(): string = "Hello, World!"


type
  GridAction* = enum
    Select
    Create
    Update
    Delete
    Submit
  GridRequest* = object
    action*: GridAction


proc parseRequest*(input: string): GridRequest =
  
  discard
