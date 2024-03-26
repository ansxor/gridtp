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

suite "Requests":
  test "Fails on incorrect header":
    try:
      discard parseRequest("meow")
      assert false, "Failed to throw error"
    except ValueError as e:
      check e.msg == "Header does not match correct format."
    
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
