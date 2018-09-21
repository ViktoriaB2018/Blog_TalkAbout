#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'TalkAbout.db'
	@db.results_as_hash = true
end

before do
	init_db
end

configure do
	init_db
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts (id INTEGER PRIMARY KEY AUTOINCREMENT, created_data DATA, content TEXT NOT NULL)'
end

get '/' do
	erb "Hello!"	
end

get '/new' do
	erb :new
end

post '/new' do
	@content = params[:content]
	erb "You tiped #{@content}"
end