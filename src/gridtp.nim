import std/asynchttpserver
import std/asyncdispatch
import gridtppkg/submodule

proc main {.async.} =
  var server = newAsyncHttpServer()

  server.listen(Port(8080))
  let port = server.getPort

  echo "http server running on localhost:" & $port.uint16
  
  while true:
    discard

when isMainModule:
  waitFor main()
