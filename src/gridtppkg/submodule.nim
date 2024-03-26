import std/streams
import std/strutils
import std/options
import std/sequtils

const
  gridTpVersion = "gridtp/1.0.0"

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
    size*: uint
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

func parseVersionHeader*(header: string): string =
  result = parseHeader(header)

  if result != gridTpVersion:
    raise newException(ValueError, "GridTP version is incompatible.")

proc readBody*(stream: Stream, bodySize: uint): GridBody =
  if bodySize == 0:
    raise newException(ValueError, "Body size must be larger than 0")
  discard
    
proc parseResponse*(input: string): GridResponse =
  var stream = newStringStream(input)
  discard parseVersionHeader(stream.readLine())
  
  if stream.atEnd():
    return

  let
    statusAndBodySize = stream.readLine().splitWhitespace()
  
  if statusAndBodySize.len != 2:
    raise newException(ValueError, "Incorrect amount of parameters for status and body size.")
  
  let
    status = parseInt(statusAndBodySize[0])
    bodySize = parseInt(statusAndBodySize[1])
  result.status = GridStatus(status)
  
  if bodySize == 0:
    return
    
  let dataType = parseHeader(stream.readLine())
  var
    bodyArr = newSeq[string]()
    line = ""
  while stream.readLine(line):
    bodyArr.add(line)
    let body = bodyArr.join("\n")
    result.body = some(GridBody(dataType: dataType, data: body))

proc parseRequest*(input: string): GridRequest =
  var stream = newStringStream(input)
  
  discard parseVersionHeader(stream.readLine())
  
  let actionPathAndBodySize = stream.readLine().splitWhitespace()

  if actionPathAndBodySize.len < 3:
    raise newException(ValueError, "Not enough parameters specified for action and path.")
  elif actionPathAndBodySize.len > 3:
    raise newException(ValueError, "Too many parameters specified for action and path.")

  result.action = case actionPathAndBodySize[0].toUpper:
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
  result.path = actionPathAndBodySize[1]
  let bodySize = parseInt(actionPathAndBodySize[2])

  if bodySize == 0:
    return
  
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
  let body = stream.readStr(bodySize)
  result.body = some(GridBody(dataType: dataType, data: body))
