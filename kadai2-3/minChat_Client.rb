# coding: utf-8
require 'socket'

socket = TCPSocket.new('127.0.0.1', 2000)

loop do
  b = gets.chomp
  socket.puts(b)

  break if b == "bye"
end
socket.close
