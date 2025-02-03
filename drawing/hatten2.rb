require 'sinatra'
require 'sinatra-websocket'
require 'json'

set :server, 'thin'  
set :sockets, []     
set :port, 2000      
set :bind, '0.0.0.0'

get '/' do
  if request.websocket?
    request.websocket do |ws|
      ws.onopen do
        settings.sockets << ws
      end

      ws.onmessage do |msg|
        settings.sockets.each { |s| s.send(msg) }
      end

      ws.onclose do
        settings.sockets.delete(ws)
      end
    end
  else
    erb :index
  end
end

Sinatra::Application.run!

