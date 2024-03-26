import options
import unittest

import gridtppkg/submodule

const
  testSelectRequest = """
#!/gridtp/1.0.0
SELECT /wiki/cool-thing.gridml
"""
  testCreateRequest = """
#!/gridtp/1.0.0
CREATE /wiki/cool-thing.gridml
"""
  testCreateWithBodyRequest = """
#!/gridtp/1.0.0
CREATE /wiki/cool-thing.gridml
#!/toml/1.0.0
email = "info@whatwhywhere.com"
message = "Hello friend"
"""

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
    
suite "Responses":
  discard
  
suite "Requests":
  test "Fails on incorrect version":
    try:
      discard parseRequest("#!/gridtp/1.0.2")
      assert false, "Failed to throw error"
    except ValueError as e:
      check e.msg == "GridTP version is incompatible."

  test "Fails on incorrect header":
    try:
      discard parseRequest("meow")
      assert false, "Failed to throw error"
    except ValueError as e:
      check e.msg == "Data header format is invalid."
    
  test "Extracts action from request (SELECT)":
    check parseRequest(testSelectRequest).action == Select

  test "Extracts action from request (CREATE)":
    check parseRequest(testCreateRequest).action == Create

  test "Fails on extraction action that doesn't exist":
    try:
      discard parseRequest("""
#!/gridtp/1.0.0
MEOW /softly
""")
      assert false, "Failed to throw error"
    except ValueError as e:
      check e.msg == "Not a valid action."

  test "Extracts path from the request":
    check parseRequest(testSelectRequest).path == "/wiki/cool-thing.gridml"

  test "Body is none when there is no body":
    check parseRequest(testCreateRequest).body.isNone

  test "Throws error if body data type is invalid":
    try:
      discard parseRequest("""
#!/gridtp/1.0.0
CREATE /softly
meow
""")
      assert false, "Failed to throw error"
    except ValueError as e:
      check e.msg == "Invalid data type format for body."

  test "Extracts correct data type format for body.":
    check parseRequest(testCreateWithBodyRequest).body.get.dataType == "toml/1.0.0"

  test "Extracts correct data for body":
    check parseRequest(testCreateWithBodyRequest).body.get.data == "email = \"info@whatwhywhere.com\"\nmessage = \"Hello friend\""
    
