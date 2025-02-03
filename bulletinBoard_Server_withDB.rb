# coding: utf-8
require 'webrick'
require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: './ouyou32.db'
)

unless ActiveRecord::Base.connection.table_exists?(:posts)
  ActiveRecord::Base.connection.create_table :posts do |t|
    t.string :user_name
    t.text :message
    t.timestamps
  end
end

class Post < ActiveRecord::Base
end

srv = WEBrick::HTTPServer.new(
  DocumentRoot: './',
  BindAddress: '127.0.0.1',
  Port: 2000
)

srv.mount_proc('/write') do |req, res|
  user = req.query['user']
  message = req.query['msg']
  res.content_type = 'text/plain'

  if user && message
    post = Post.create(user_name: user, message: message)
    res.body = "ID: #{post.id}"
  else
    res.status = 400
    res.body = "Error: no 'user' or 'msg' parameter"
  end
end

srv.mount_proc('/index') do |req, res|
  res.content_type = 'text/plain'
  posts = Post.all
  res.body = posts.map { |post| "#{post.user_name}, #{post.id}" }.join("\n")
end

srv.mount_proc('/read') do |req, res|
  id = req.query['id'].to_i
  res.content_type = 'text/plain'
  post = Post.find_by(id: id)

  if post
    res.body = "#{post.user_name}, #{post.message}"
  else
    res.status = 404
    res.body = "Error: Message with ID #{id} not found"
  end
end

trap("INT") { srv.shutdown }

puts "Server is running at http://127.0.0.1:2000"
srv.start
