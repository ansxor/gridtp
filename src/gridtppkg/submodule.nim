import std/streams
import std/strutils
import std/options

type
  GridAction* = enum
    Select
    Create
    Update
    Delete
    Submit
  GridStatus* = enum
    ValidRequest = 0
    ClientError = 1
    ServerError = 2
    VersionMismatch = 3
    Unknown
  GridBody* = object
    dataType*: string
    data*: string
  GridRequest* = object
    action*: GridAction
    path*: string
    body*: Option[GridBody]
  GridResponse* = object
    status*: GridStatus
    body*: Option[GridBody]

func parseHeader*(header: string): string =
  if not (header.startsWith("#!/")):
    raise newException(ValueError, "Data header format is invalid.")
  header.split("#!/")[1]
    
proc parseResponse*(input: string): GridResponse =
  discard

proc parseRequest*(input: string): GridRequest =
  var stream = newStringStream(input)
  
  let header = parseHeader(stream.readLine())

  if header != "gridtp/1.0.0":
    raise newException(ValueError, "GridTP version is incompatible.")
  
  let actionAndPath = stream.readLine().splitWhitespace()

  if actionAndPath.len < 2:
    raise newException(ValueError, "Not enough parameters specified for action and path.")
  elif actionAndPath.len > 2:
    raise newException(ValueError, "Too many parameters specified for action and path.")

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
                      raise newException(ValueError, "Not a valid action.")
  result.path = actionAndPath[1]

  let bodyType = try:
                   some(stream.readLine())
                 except:
                   none(string)

  if bodyType.isNone:
    return
  
  let dataType = try:
                   parseHeader(bodyType.get)
                 except:
                   raise newException(ValueError, "Invalid data type format for body.")
  var
    bodyArr = newSeq[string]()
    line = ""
  while stream.readLine(line):
    bodyArr.add(line)
  let body = bodyArr.join("\n")
  result.body = some(GridBody(dataType: dataType, data: body))
