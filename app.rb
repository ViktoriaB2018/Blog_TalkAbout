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
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts (id INTEGER PRIMARY KEY AUTOINCREMENT, created_data DATA, name, content)'

	@db.execute 'CREATE TABLE IF NOT EXISTS Comments (id INTEGER PRIMARY KEY AUTOINCREMENT, created_data DATA, comment, post_id INTEGER)'
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
	@name = params[:name]

	# хеш для валидации
	hh = { 	:content => 'Type your text',
			:name => 'Type your name' }

	@error = hh.select {|key,_| params[key] == ""}.values.join(", ")

	if @error != ""
		return erb :new
	else
		# сохранение данных в БД
		@db.execute 'INSERT INTO Posts (created_data, name, content) VALUES (datetime(), ?, ?)', [@name, @content]
		
		# перенаправление на главную страницу
		redirect to '/'
	end
end

# вывод информации о посте
get '/details/:post_id' do

	# получаем переменную из url'а
	post_id = params[:post_id]

	# получаем список постов (у нас 1 пост)
	@results = @db.execute 'SELECT * FROM Posts where id = ?', [post_id]

	# выбираем этот один пост в переменную @row
	@row = @results[0]

	# выбираем комментарии для поста
	@comments = @db.execute 'SELECT * FROM Comments where post_id = ? order by id', [post_id]

	erb :details
end

# обработчик post-запроса 
# браузер отправляет данные на сервер, а мы их принимаем
post '/details/:post_id' do
	# получаем переменную из url'а
	post_id = params[:post_id]
	comment = params[:comment]

	# валидация 
	if comment.size == 0
		@error = 'Type comment'

		@results = @db.execute 'SELECT * FROM Posts where id = ?', [post_id]

		@row = @results[0]

		@comments = @db.execute 'SELECT * FROM Comments where post_id = ? order by id', [post_id]

		erb :details
	else
		# сохранение данных в БД
		@db.execute 'INSERT INTO Comments (created_data, comment, post_id) VALUES (datetime(), ?, ?)', [comment, post_id]
			
		# перенаправление на страницу поста
		redirect to('/details/' + post_id)
	end

end