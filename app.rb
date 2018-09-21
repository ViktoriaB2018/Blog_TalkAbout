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
	# инициализация БД
	init_db
end

# вызывается каждый раз при конфигурации приложения: когда изменился код программы и перезагрузилась страница
configure do
	# инициализация БД
	init_db

	# создать таблицу, если таблицы не существует
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts (id INTEGER PRIMARY KEY AUTOINCREMENT, created_data DATA, content TEXT NOT NULL)'
end

get '/' do
	# выводим список постов из БД
	@results = @db.execute 'SELECT * FROM Posts order by id desc'

	erb :index
end

# обработчик get-запроса /new
# браузер получет страницу с сервера
get '/new' do
	erb :new
end

# обработчик post-запроса /new
# браузер отправляет данные на сервер
post '/new' do
	# получаем переменную из пост запроса
	@content = params[:content]

	# проверка на пустое значение 
	if @content.size == 0
		@error = 'Type text'
		erb :new
	else
		# сщхранение данных в БД
		@db.execute 'INSERT INTO Posts (created_data, content) VALUES (datetime(), ?)', [@content]
		
		# перенаправление на главную страницу
		redirect to '/'
	end
end

# вывод информации о посте
get '/details/:post_id' do
	post_id = params[:post_id]
	erb "Information for id #{post_id}"
end