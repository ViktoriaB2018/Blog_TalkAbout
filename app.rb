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