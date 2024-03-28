import std/net
import std/socketstreams
import std/strutils
import std/mimetypes
import std/paths
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

      if gridReq.action == Select:
        var m = newMimetypes()
        let
          filePath = gridReq.path
          path = Path("static") / Path(filePath)
          file = readFile(string(path))
          extension = file[file.rfind('.')+1..^1]
          mimeType = m.getMimetype(extension)
        client.send(fmt"""#!/gridtp/1.0.0
0 {file.len}
#!/{mimeType}
{file}""")
        echo "sent file: " & filePath
      else:
        client.send("""#!/gridtp/1.0.0
1 0""")
    except ValueError as e:
      echo e.msg
      client.send("""#!/gridtp/1.0.0
1 0""")
    except IOError as e:
      echo e.msg
      client.send("""#!/gridtp/1.0.0
2 0""")
    client.close()
