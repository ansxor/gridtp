import std/streams

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
  
  let actionAndPath = stream.readLine()
  
  discard
