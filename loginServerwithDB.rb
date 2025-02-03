# coding: utf-8
require 'webrick'
require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: './ouyou23.db'
)

unless ActiveRecord::Base.connection.table_exists?(:users)
  ActiveRecord::Base.connection.create_table :users do |t|
    t.string :username
    t.string :password
    t.timestamps
  end
end

class User < ActiveRecord::Base
end

if User.count == 0
  User.create(username: 'yamada', password: 'password')
  User.create(username: 'tanaka', password: 'password2')
end

srv = WEBrick::HTTPServer.new(
  DocumentRoot: './',
  BindAddress: '127.0.0.1',
  Port: 2000
)

srv.mount_proc('/login') do |req, res|
  if req.request_method == 'POST'
    username = req.query['user']
    password = req.query['password']
    res.content_type = 'text/html; charset=UTF-8'

    user = User.find_by(username: username, password: password)
    if user
      res.body = "ログイン成功: ユーザー名とパスワードが一致しました。"
    else
      res.body = "ログイン失敗: ユーザー名またはパスワードが無効です。"
    end
  else
    res.status = 400
    res.body = "不正なリクエストです。"
  end
end

srv.mount_proc('/') do |req, res|
  res.body = <<~HTML
    <!DOCTYPE html>
    <html lang="ja">
    <head>
      <meta charset="UTF-8">
    </head>
    <body>
      <form action="/login" method="POST">
        <input type="text" name="user" placeholder="ユーザー名"><br>
        <input type="password" name="password" placeholder="パスワード"><br>
        <input type="submit" value="ログイン">
      </form>
    </body>
    </html>
  HTML
  res['Content-Type'] = 'text/html; charset=UTF-8'
end

trap('INT') { srv.shutdown }

puts "Server is running at http://127.0.0.1:2000"
srv.start
