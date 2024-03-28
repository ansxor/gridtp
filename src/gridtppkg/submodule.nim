import std/streams
import std/strutils
import std/options

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
    size*: int
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

proc readBody*(stream: Stream, bodySize: int): GridBody =
  if bodySize == 0:
    raise newException(ValueError, "Body size must be larger than 0")

  result.size = bodySize
  try:
    result.dataType = parseHeader(stream.readLine())
  except ValueError:
    raise newException(ValueError, "Invalid data type format for body.")
  result.data = stream.readStr(cast[int](bodySize))

proc parseResponse*(stream: Stream): GridResponse =
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

  result.body = some(readBody(stream, bodySize))

proc parseRequest*(stream: Stream): GridRequest =
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

  let body = readBody(stream, bodySize)
  result.body = some(body)
