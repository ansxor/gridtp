# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import gridtppkg/submodule


test "correct welcome":
  check getWelcomeMessage() == "Hello, World!"

suite "Requests":
  test "Able to extract action from request (SELECT)":
    let testRequest = """
#!/gridtp/1.0.0
SELECT /wiki/cool-thing.gridml
  """
    check parseRequest(testRequest).action == Select

  test "Able to extract action from request (CREATE)":
    let testRequest = """
#!/gridtp/1.0.0
CREATE /wiki/cool-thing.gridml
  """
    check parseRequest(testRequest).action == Create
