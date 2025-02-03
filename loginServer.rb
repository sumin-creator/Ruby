# coding: utf-8
require 'webrick'

PASSWORD_FILE = 'List.txt'

def load(file)
  passwords = []
  File.open(file, 'r') do |f|
    f.each_line do |line|
      passwords << line.chomp
    end
  end
  passwords
end

passwords = load(PASSWORD_FILE)

srv = WEBrick::HTTPServer.new(
  DocumentRoot: './',
  BindAddress: '127.0.0.1',
  Port: 2000
)

srv.mount_proc '/login' do |req, res|
  if req.request_method == 'POST'
    password1 = req.query['password']

    if passwords.include?(password1)
      res.body = "ログイン成功: パスワードが正しいです。"
    else
      res.body = "ログイン失敗: パスワードが無効です。"
    end
  else
    res.body = "不正なリクエストです。"
  end

  res['Content-Type'] = 'text/html; charset=UTF-8'
end

srv.mount_proc '/' do |req, res|
  res.body = <<~HTML
    <!DOCTYPE html>
    <html lang="ja">
    <head>
      <meta charset="UTF-8">
    </head>
    <body>
      <form action="/login" method="POST">
        <input type="text" name="password"><br>
        <input type="submit">
      </form>
    </body>
    </html>
  HTML
  res['Content-Type'] = 'text/html; charset=UTF-8'
end

trap('INT') { srv.shutdown }

srv.start
