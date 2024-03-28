require 'socket'

sock = TCPSocket.new('localhost', 8080)
body = "meow"
sock.write("#!/gridtp/1.0.0
SELECT /meow.org 0
")

header = sock.gets
status, bodySizeStr = sock.gets.split(' ')
bodySize = bodySizeStr.to_i

if bodySize > 0 then
  type = sock.gets
  data = sock.read(bodySize)

  puts type
  puts data
end

sock.close
