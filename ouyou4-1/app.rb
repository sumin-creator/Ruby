# coding: utf-8
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'date'

enable :sessions

DB = SQLite3::Database.new "ouyou41.db"
DB.results_as_hash = true

USERS = {
  "sano" => "hideto",
  "ouno" => "shuto"
}

get '/' do
  @error = session.delete(:error)
  erb :login
end

post '/login' do
  user_id = params[:user_id]
  password = params[:password]

  if USERS[user_id] == password
    session[:user_id] = user_id
    redirect '/board'
  else
    session[:error] = "ログインできませんでした。"
    redirect '/'
  end
end

get '/board' do
  redirect '/' unless session[:user_id]
  @user_id = session[:user_id]
  @messages = DB.execute("SELECT * FROM messages ORDER BY created_at DESC")
  erb :board
end

post '/board' do
  redirect '/' unless session[:user_id]

  message = params[:message]
  user_id = session[:user_id]
  created_at = DateTime.now.to_s

  DB.execute("INSERT INTO messages (user_id, message, created_at) VALUES (?, ?, ?)", [user_id, message, created_at])
  redirect '/board'
end

get '/logout' do
  session.clear
  redirect '/'
end
