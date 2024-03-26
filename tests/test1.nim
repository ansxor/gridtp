# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

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
    
  test "Able to extract action from request (SELECT)":
    check parseRequest(testSelectRequest).action == Select

  test "Able to extract action from request (CREATE)":
    check parseRequest(testCreateRequest).action == Create
