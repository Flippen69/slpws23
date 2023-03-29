require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'date'
require 'active_support/time'
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

# get('/posts') do
#   id = session[:id].to_i
#   db = SQLite3::Database.new('db/db_forum.db')
#   db.results_as_hash = true
#   result = db.execute("SELECT posts.id, posts.title, posts.content, users.name FROM posts INNER JOIN users ON posts.user_id = users.id WHERE user_id = ?", id)
#   slim(:"posts/index", locals:{posts:result})
# end

get('/posts') do
  id = session[:id].to_i
  db = SQLite3::Database.new('db/db_forum.db')
  db.results_as_hash = true
  result = db.execute("SELECT posts.id, posts.title, posts.content, users.name FROM posts INNER JOIN users ON posts.user_id = users.id WHERE user_id = ?", id)
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
    if result
      pwdigest = result["pwdigest"]
      id = result["id"]
      if BCrypt::Password.new(pwdigest) == password
        
        session[:id] = id
        redirect('/posts')
      else
        "Fel lösenord eller användaren finns inte!"
      end
    end
end

post('/post') do
  post_title = params[:post_title]
  post_content = params[:post]
  user_id = session[:id]
  db = SQLite3::Database.new('db/db_forum.db')
  db.execute("INSERT INTO posts (title, content, user_id) VALUES (?,?,?)", post_title, post_content, user_id)
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

get('/all_posts') do
  db = SQLite3::Database.new('db/db_forum.db')
  post_title = params[:post_title]
  db.results_as_hash = true
  # @all_posts = db.execute("SELECT posts.title, posts.content, users.name FROM posts INNER JOIN users ON posts.user_id = users.id")
  @all_posts = db.execute("SELECT posts.title, posts.content, posts.created_at, users.name FROM posts INNER JOIN users ON posts.user_id = users.id")

  slim(:all_posts)
end

post('/like/:id') do
  # get the id of the post being liked from the url
  id = params[:id].to_i
  
  # retrieve the current number of likes from the database
  db = SQLite3::Database.new('db/db_forum.db')
  likes = db.execute("SELECT likes FROM posts WHERE id = ?", id).first["likes"]
  
  # increment the number of likes by 1
  new_likes = likes + 1
  
  # update the database with the new number of likes
  db.execute("UPDATE posts SET likes = ? WHERE id = ?", new_likes, id)
  
  # redirect back to the all_posts page
  redirect('/all_posts')
end

get('/support') do

  slim(:support)
end
