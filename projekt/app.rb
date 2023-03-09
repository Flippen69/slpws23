require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative 'authenticationMiddleware.rb'
enable :sessions

# use AuthMiddleware

get('/') do
    slim(:register)
end

get('/register') do
  slim(:register)
end

get('/showlogin') do
    slim(:login)
end

get('/posts') do
    id = session[:id].to_i
    db = SQLite3::Database.new('db/db_forum.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM posts WHERE user_id = ?", id)
    slim(:"posts/index", locals:{posts:result})
end

get('/logout') do 
  session[:id] = nil
  redirect("/")
end

post('/login') do
    username = params[:username]
    password = params[:password]
    db = SQLite3::Database.new('db/db_forum.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE name= ?", username).first
    pwdigest = result["pwdigest"]
    id = result["id"]
  
    if BCrypt::Password.new(pwdigest) == password
      
      session[:id] = id
      redirect('/posts')
    else
      "FEL LÖSEN!"
    end
end
  
post('/post') do
    post = params[:post]
    id = session[:id]
    db = SQLite3::Database.new('db/db_forum.db')
    db.execute("INSERT INTO posts (content, user_id) VALUES (?,?)",post, id)
    redirect('/posts')
end
  
post('/post/:id/delete') do
    id = params[:id].to_i
    db = SQLite3::Database.new('db/db_forum.db')
    db.execute("DELETE FROM posts WHERE id = ?", id)
    redirect('/posts')
end
  
post('/post/:id/update') do
    id = params[:id].to_i
    edit_post = params[:edit_post]
    db = SQLite3::Database.new('db/db_forum.db')
    db.execute("UPDATE posts SET content=? WHERE id=?", edit_post, id)
    redirect('/posts')
end

  
post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
  
    if (password == password_confirm)
      password_digest = BCrypt::Password.create(password)
      db = SQLite3::Database.new('db/db_forum.db')
      db.execute("INSERT INTO users (name,pwdigest) VALUES (?,?)", username,password_digest)
      redirect('/')
    else
      "lösen mathcade inte"
    end
end

get('/support') do

  slim(:support)
end

get('/all_posts') do
  db = SQLite3::Database.new('db/db_forum.db')
  db.results_as_hash = true
  @all_posts = db.execute("SELECT posts.content, users.name FROM posts INNER JOIN users ON posts.user_id = users.id")

  slim(:all_posts)
end