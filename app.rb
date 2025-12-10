require 'sinatra'
require 'sqlite3'
require 'slim'
require 'sinatra/reloader'
require 'sinatra/flash'

enable :sessions

# Funktion för att prata med databasen
# Exempel på användning: db.execute('SELECT * FROM fruits')
def db(hash = true)
  return @db if @db

  @db = SQLite3::Database.new("db/todos.db")
  if hash
    @db.results_as_hash = true
  else
    @db.results_as_hash = false
  end

  return @db
end

require_relative 'login.rb'

# Routen /
get('/') do
  # Bygg SQL-query:t
  query_unfin = "SELECT * FROM todos WHERE"
  if !["", nil].include?(@query = params[:q])
    query_unfin << " name LIKE '%#{@query.upcase}%' AND"
  end
  query_unfin << " done="
  query_fin = query_unfin + "1"
  query_unfin << "0"

  # Skickar queries till databasen
  @unfinished = db.execute(query_unfin)
  @finished = db.execute(query_fin)
  @categories = db.execute("SELECT * FROM categories")

  @unfinished.each do |todo|
    categories = db.execute("SELECT DISTINCT name FROM categories WHERE id IN (SELECT cat_id FROM todo_cat_rel WHERE todo_id == #{todo["id"]})").map{|x| x["name"]}
    todo["category"] = categories
  end
  @finished.each do |todo|
    categories = db.execute("SELECT DISTINCT name FROM categories WHERE id IN (SELECT cat_id FROM todo_cat_rel WHERE todo_id == #{todo["id"]})").map{|x| x["name"]}
    todo["category"] = categories
  end

  if !["", nil].include?(catfilter = params[:cat])
    @finished = @finished.reject{|todo| !todo["category"].include?(catfilter)}
    @unfinished = @unfinished.reject{|todo| !todo["category"].include?(catfilter)}
  end

  slim(:index)
end

get('/new') do
  @categories = db.execute("SELECT * FROM categories")
  slim(:new)
end

post('/new') do
    todo_info = [params[:name], params[:notes]]
    if categories = params[:cat]
      categories = categories.values
    end

    if db.execute("INSERT INTO todos (name, notes, done) VALUES (?,?,0)",todo_info)
      if categories != nil
        todo_id = db.execute("SELECT id FROM todos WHERE name LIKE ?",todo_info[0]).last["id"]
        categories.each {|cat| db.execute("INSERT INTO todo_cat_rel (todo_id, cat_id) VALUES (?,?)",[todo_id,cat])}
      end
      flash[:new] = "Info: todo successfully added"
    else
      flash[:new] = "Error: todo could not be added to database"
    end
    redirect('/')
end

post('/:id/delete') do
  to_delete = params[:id].to_i

  if db.execute("DELETE FROM todos WHERE id=?",to_delete)
    db.execute("DELETE FROM todo_cat_rel WHERE todo_id=?",to_delete)
    flash[:delete] = "Info: Todo successfully deleted"
  else
    flash[:delete] = "Error: Todo could not be deleted"
  end
  redirect('/')
end

get('/:id/edit') do
  id = params[:id].to_i
  
  @todo = db.execute("SELECT * FROM todos WHERE id=?",id).first
  @categories = db.execute("SELECT * FROM categories")

  slim(:edit)
end

post('/:id/edit') do
    todo = [params[:name], params[:notes], params[:id].to_i]
    categories = params[:cat].values
    old = db.execute("SELECT * FROM todos WHERE id=?",todo[-1]).first

    if db.execute("UPDATE todos SET name=?, notes=? WHERE id=?",todo)
      if categories != nil
        db.execute("DELETE FROM todo_cat_rel WHERE todo_id=?", todo[-1])
        categories.each {|cat| db.execute("INSERT INTO todo_cat_rel (todo_id, cat_id) VALUES (?,?)",[todo[-1],cat])}
      end

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