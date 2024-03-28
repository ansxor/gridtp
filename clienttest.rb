require 'socket'

sock = TCPSocket.new('localhost', 8080)
body = "meow"
sock.write("#!/gridtp/1.0.0
SELECT meow #{body.length}
#!/text
#{body}")

header = sock.gets
status = sock.gets

puts header
puts status
puts "==="

sock.close
