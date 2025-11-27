require 'sinatra'
require 'sqlite3'
require 'slim'
require 'sinatra/reloader'
require 'sinatra/flash'

enable :sessions

# Funktion för att prata med databasen
# Exempel på användning: db.execute('SELECT * FROM fruits')
def db
  return @db if @db

  @db = SQLite3::Database.new("db/todos.db")
  @db.results_as_hash = true

  return @db
end

require_relative 'login.rb'

# Routen /
get('/') do #FRAMTIDA MELKER: BYGG SQL INPUT!
  if (@query = params[:q]) != nil
    @unfinished = db.execute("SELECT * FROM todos WHERE (name,done) LIKE (?,0)","%#{@query.upcase}")
    @finished = db.execute("SELECT * FROM todos WHERE (name,done) LIKE (?,1)","%#{@query.upcase}")
  else
    @unfinished = db.execute("SELECT * FROM todos WHERE done=0")
    @finished = db.execute("SELECT * FROM todos WHERE done=1")
  end

  slim(:index)
end

get('/new') do
    slim(:new)
end

post('/new') do
    todo_info = [params[:name], params[:notes]]

    if db.execute("INSERT INTO todos (name, notes, done) VALUES (?,?,0)",todo_info)
        flash[:new] = "Info: todo successfully added"
    else
        flash[:new] = "Error: todo could not be added to database"
    end
    redirect('/')
end

post('/:id/delete') do
  to_delete = params[:id].to_i

  if db.execute("DELETE FROM todos WHERE id=?",to_delete)
    flash[:delete] = "Info: Todo successfully deleted"
  else
    flash[:delete] = "Error: Todo could not be deleted"
  end
  redirect('/')
end

get('/:id/edit') do
  id = params[:id].to_i
  
  @todo = db.execute("SELECT * FROM todos WHERE id=?",id).first

  slim(:edit)
end

post('/:id/edit') do
    todo = [params[:name], params[:notes], params[:id].to_i]
    old = db.execute("SELECT * FROM todos WHERE id=?",todo[-1]).first

    if db.execute("UPDATE todos SET name=?, notes=? WHERE id=?",todo)
        if todo[0] != old["name"]
            flash[:name] = "Info: name successfully changed to #{todo[0]}"
        end
        if todo[1] != old["notes"]
            flash[:amount] = "Info: notes successfully changed"
        end
    else
        flash[:edit] = "Error: could not edit todo"
    end
    redirect('/')
end

post('/:id/toggledone') do
  id = params[:id].to_i
  status = db.execute("SELECT done FROM todos WHERE id=?",id).first
  if status["done"] == 1
    if db.execute("UPDATE todos SET done=0 WHERE id=?",id)
      flash[:toggle] = "Info: todo succesfully marked incomplete"
    end
  elsif status["done"] == 0
    if db.execute("UPDATE todos SET done=1 WHERE id=?",id)
      flash[:toggle] = "Info: todo succesfully marked complete"
    end
  end
  redirect('/')
end