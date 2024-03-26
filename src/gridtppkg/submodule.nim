import std/streams
import std/strutils

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
  var stream = newStringStream(input)
  
  let header = stream.readLine()

  if header != "#!/gridtp/1.0.0":
    raise newException(ValueError, "Header does not match correct format.")
  
  let actionAndPath = stream.readLine().splitWhitespace()

  if actionAndPath.len < 2:
    raise newException(ValueError, "Not enough parameters specified for action and path")
  elif actionAndPath.len > 2:
    raise newException(ValueError, "Too many parameters specified for action and path")

  result.action = case actionAndPath[0].toUpper:
                    of "SELECT":
                      Select
                    of "CREATE":
                      Create
                    of "UPDATE":
                      Update
                    of "DELETE":
                      Delete
                    of "SUBMIT":
                      Submit
                    else:
                      raise newException(ValueError, "Not a valid action")
  
  discard
