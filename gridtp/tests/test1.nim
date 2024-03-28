import options
import std/streams
import unittest

import gridtp

const
  testSelectRequest = """
#!/gridtp/1.0.0
SELECT /wiki/cool-thing.gridml 0
"""
  testCreateRequest = """
#!/gridtp/1.0.0
CREATE /wiki/cool-thing.gridml 0
"""
  testCreateWithBodyRequest = """
#!/gridtp/1.0.0
CREATE /wiki/cool-thing.gridml 56
#!/toml/1.0.0
email = "info@whatwhywhere.com"
message = "Hello friend""""
  testCreateBody = """#!/toml/1.0.0
email = "info@whatwhywhere.com"
message = "Hello friend""""
  testCreateBodySize = 56
  
suite "Parse header":
  test "Check for gridtp header extraction":
    check parseHeader("#!/gridtp/1.0.0") == "gridtp/1.0.0"

  test "Check for toml header extraction":
    check parseHeader("#!/toml/1.0.0") == "toml/1.0.0"
    
  test "Check for error being thrown on bad header format":
    try:
      discard parseHeader("meow")
      assert false, "Failed to throw error"
    except ValueError as e:
      check e.msg == "Data header format is invalid."

suite "Parse version header":
  test "Correct version":
    check parseVersionHeader("#!/gridtp/1.0.0") == "gridtp/1.0.0"
    
  test "Incorrect format":
    try:
      discard parseHeader("meow")
      assert false, "Failed to throw error"
    except ValueError as e:
      check e.msg == "Data header format is invalid."
  
  test "Incorrect version":
    try:
      discard parseRequest(newStringStream("#!/gridtp/1.0.2"))
      assert false, "Failed to throw error"
    except ValueError as e:
      check e.msg == "GridTP version is incompatible."

suite "Reading body":
  test "Successfully extracts data type and body data":
    let body = readBody(newStringStream(testCreateBody), testCreateBodySize)
    check body.dataType == "toml/1.0.0"
    check body.data == "email = \"info@whatwhywhere.com\"\nmessage = \"Hello friend\""
    check body.size == testCreateBodySize
  
  test "Body size must be larger than 0":
    try:
      discard readBody(newStringStream(""), 0)
      assert false, "Failed to throw error"
    except ValueError as e:
      check e.msg == "Body size must be larger than 0"
      
suite "Responses":
  test "Empty response":
    let response = parseResponse(newStringStream("""#!/gridtp/1.0.0
0 0"""))
    check response.status == ValidRequest
    check response.body.isNone

  test "Empty body with client error":
    let response = parseResponse(newStringStream("""#!/gridtp/1.0.0
1 0"""))
    check response.status == ClientError
    check response.body.isNone

  test "Incorrect parameters for status":
    try:
      discard parseResponse(newStringStream("""#!/gridtp/1.0.0
0"""))
      assert false, "Failed to throw error"
    except ValueError as e:
      check e.msg == "Incorrect amount of parameters for status and body size."
  
  test "Successful response with body":
    let response = parseResponse(newStringStream("""#!/gridtp/1.0.0
0 91
#!/gridml/1.0.0
~metadata{
  ~title(key){The Cool Thing}
}
~document{
  ~p{Let's grid this party started}
}"""))
    check response.status == ValidRequest
    check response.body.get.dataType == "gridml/1.0.0"
  
  test "Response with status code and body":
    let response = parseResponse(newStringStream("""#!/gridtp/1.0.0
1 91
#!/gridml/1.0.0
~metadata{
  ~title(key){The Cool Thing}
}
~document{
  ~p{Let's grid this party started}
}"""))
    check response.status == ClientError
    check response.body.get.dataType == "gridml/1.0.0"

    
suite "Requests":
  test "Fails on incorrect version":
    try:
      discard parseRequest(newStringStream("#!/gridtp/1.0.2"))
      assert false, "Failed to throw error"
    except ValueError as e:
      check e.msg == "GridTP version is incompatible."

  test "Fails on incorrect header":
    try:
      discard parseRequest(newStringStream("meow"))
      assert false, "Failed to throw error"
    except ValueError as e:
      check e.msg == "Data header format is invalid."
    
  test "Extracts action from request (SELECT)":
    check parseRequest(newStringStream(testSelectRequest)).action == Select

  test "Extracts action from request (CREATE)":
    check parseRequest(newStringStream(testCreateRequest)).action == Create

  test "Fails on extraction action that doesn't exist":
    try:
      discard parseRequest(newStringStream("""
#!/gridtp/1.0.0
MEOW /softly 0
"""))
      assert false, "Failed to throw error"
    except ValueError as e:
      check e.msg == "Not a valid action."

  test "Extracts path from the request":
    check parseRequest(newStringStream(testSelectRequest)).path == "/wiki/cool-thing.gridml"

  test "Body is none when there is no body":
    check parseRequest(newStringStream(testCreateRequest)).body.isNone

  test "Throws error if body data type is invalid":
    try:
      discard parseRequest(newStringStream("""
#!/gridtp/1.0.0
CREATE /softly 4
meow
"""))
      assert false, "Failed to throw error"
    except ValueError as e:
      check e.msg == "Invalid data type format for body."

  test "Extracts correct data type format for body.":
    check parseRequest(newStringStream(testCreateWithBodyRequest)).body.get.dataType == "toml/1.0.0"

  test "Extracts correct data for body":
    check parseRequest(newStringStream(testCreateWithBodyRequest)).body.get.data == "email = \"info@whatwhywhere.com\"\nmessage = \"Hello friend\""
    
