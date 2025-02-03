# coding: utf-8
require 'socket'

server = TCPServer.new(2000)

client = server.accept

loop do
  b = client.gets.chomp
  break if b == "bye"
  puts "#{b}"
end

client.close
server.close
