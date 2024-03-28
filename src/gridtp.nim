import std/net
import std/socketstreams
import gridtppkg/submodule
import strformat

when isMainModule:
  let socket = newSocket()
  socket.bindAddr(Port(8080))
  socket.listen()

  echo "Listening on localhost:8080"

  while true:
    var
      client: Socket
      address = ""
    socket.acceptAddr(client, address)
    var stream = newReadSocketStream(client)
    try:
      let gridReq = parseRequest(stream)
      let returnBody = gridReq.path
      client.send(fmt"""#!/gridtp/1.0.0
0 {returnBody.len}
#!/text
{returnBody}""")

    except ValueError as e:
      echo e.msg
      client.send("""#!/gridtp/1.0.0
1 0""")
    except IOError as e:
      echo e.msg
      client.send("""#!/gridtp/1.0.0
2 0""")
    client.close()
