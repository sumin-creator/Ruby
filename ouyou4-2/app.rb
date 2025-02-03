# coding: utf-8
require 'sinatra'
require 'sqlite3'
require 'erb'

DB = SQLite3::Database.new "favorite_websites.db"
DB.results_as_hash = true

enable :sessions

set :bind, '127.0.0.1'
set :port, 2000

def create_tables
  DB.execute <<-SQL
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY,
      username TEXT,
      password TEXT
    );
  SQL

  DB.execute <<-SQL
    CREATE TABLE IF NOT EXISTS websites (
      id INTEGER PRIMARY KEY,
      user_id INTEGER,
      title TEXT,
      url TEXT,
      FOREIGN KEY (user_id) REFERENCES users(id)
    );
  SQL
end

create_tables

def create_initial_user
  existing_user = DB.execute("SELECT * FROM users WHERE username = 'sano'").first
  if existing_user.nil?
    DB.execute("INSERT INTO users (username, password) VALUES (?, ?)", ['sano', 'hideto'])
  end
end

create_initial_user

get '/' do
  erb :index
end

post '/login' do
  username = params[:username]
  password = params[:password]
  if username == 'sano' && password == 'hideto'
    session[:user_id] = 1 
    redirect '/weblist'
  else
    redirect '/'
  end
end

get '/logout' do
  session.clear
  redirect '/'
end

get '/weblist' do
  if session[:user_id]
    user_id = session[:user_id]
    @websites = DB.execute("SELECT * FROM websites WHERE user_id = ?", [user_id])
    erb :weblist
  else
    redirect '/'
  end
end

post '/add_website' do
  if session[:user_id]
    user_id = session[:user_id]
    title = params[:title]
    url = params[:url]
    
    DB.execute("INSERT INTO websites (user_id, title, url) VALUES (?, ?, ?)", [user_id, title, url])
    redirect '/weblist'
  else
    redirect '/'
  end
end

