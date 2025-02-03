# coding: utf-8
require 'webrick'

class BulletinBoard
  def initialize
    @posts = {}
    @index = 1
    @forbidden_words = ['aho', 'unko', 'fuck']
    @server = WEBrick::HTTPServer.new(
      DocumentRoot: './',
      BindAddress: '127.0.0.1',
      Port: 2000
    )
    
    route
  end

  def route
    @server.mount_proc('/write') do |req, res|
      d = req.query['msg']
      if d.nil? || forbidden(d)
        res.status = 400
      else
        id = @index
        @posts[id] = d
        @index += 1
        res.body = "ID: #{id}"
      end
      res.content_type = 'text/plain'
    end

    @server.mount_proc('/index') do |req, res|
      res.content_type = 'text/plain'
      res.body = @posts.keys.map { |id| "id:#{id}" }.join("\n")
    end

    @server.mount_proc('/read') do |req, res|
      id = req.query['id'].to_i
      if @posts.key?(id)
        res.content_type = 'text/plain'
        res.body = @posts[id]
      else
        res.status = 404
      end
    end
  end

  def forbidden(d)
    @forbidden_words.any? { |word| d.include?(word) }
  end

  def start
    trap("INT") { @server.shutdown }
    @server.start
  end
end

BulletinBoard.new.start
