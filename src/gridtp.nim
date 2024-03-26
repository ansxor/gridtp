import std/asynchttpserver
import std/asyncdispatch
import gridtppkg/submodule
import strformat

proc main {.async.} =
  var server = newAsyncHttpServer()

  proc cb(req: Request) {.async.} =
    try:
      let body = req.body
      let gridReq = parseRequest(body)
      let returnBody = gridReq.path
      await req.respond(Http200, fmt"""#!/gridtp/1.0.0
0 {returnBody.len}
#!/text
{returnBody}""")
    except ValueError as e:
      echo e.msg
      await req.respond(Http200, """#!/gridtp/1.0.0
1 0""")
    except IOError as e:
      echo e.msg
      await req.respond(Http200, """#!/gridtp/1.0.0
2 0""")
  
  server.listen(Port(8080))
  let port = server.getPort

  echo "http server running on localhost:" & $port.uint16
  
  while true:
    if server.shouldAcceptRequest():
      await server.acceptRequest(cb)
    else:
      await sleepAsync(500)

when isMainModule:
  waitFor main()
