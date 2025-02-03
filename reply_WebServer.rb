# coding: utf-8
require 'webrick'

def fizzbuzz_html(num)
  html = "<html><head><title>FizzBuzz Result</title></head><body>"
  html += "<h1>FizzBuzz Result for 1 to #{num}</h1>"
  html += "<table border='1'><tr><th>Number</th><th>Result</th></tr>"
  
  (1..num).each do |i|
    result = case
             when i % 15 == 0 then "Fizz Buzz"
             when i % 3 == 0  then "Fizz"
             when i % 5 == 0  then "Buzz"
             else i
             end
    html += "<tr><td>#{i}</td><td>#{result}</td></tr>"
  end
  
  html += "</table></body></html>"
  return html
end

srv = WEBrick::HTTPServer.new({
  :DocumentRoot => './',
  :BindAddress => '127.0.0.1',
  :Port => 2000
})

srv.mount_proc('/time') do |req, res|
  current_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
  res.content_type = 'text/html'
  res.body = "<html><head><title>Current Time</title></head><body><h1>Current Time: #{current_time}</h1></body></html>"
end

srv.mount_proc('/fizzbuzz') do |req, res|
  num = req.query['num'].to_i
  res.content_type = 'text/html'
  if num > 0
    res.body = fizzbuzz_html(num)
  else
    res.body = "<html><head><title>Error</title></head><body><h1>Please Provide a 'num' Parameter</h1></body></html>"
  end
end

trap("INT") { srv.shutdown }

puts "Server is running at http://127.0.0.1:2000"
srv.start
