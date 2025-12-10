require 'sqlite3'

db = SQLite3::Database.new("db/todos.db")


def seed!(db)
  puts "Using db file: db/todos.db"
  puts "🧹 Dropping old tables..."
  drop_tables(db)
  puts "🧱 Creating tables..."
  create_tables(db)
  puts "🍎 Populating tables..."
  populate_tables(db)
  puts "✅ Done seeding the database!"
end

def drop_tables(db)
  db.execute('DROP TABLE IF EXISTS todos')
  db.execute('DROP TABLE IF EXISTS categories')
  db.execute('DROP TABLE IF EXISTS todo_cat_rel')
end

def create_tables(db)
  db.execute('CREATE TABLE todos (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL, 
              notes TEXT,
              done BOOLEAN DEFAULT 0)')
  db.execute('CREATE TABLE categories (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL)')
  db.execute('CREATE TABLE todo_cat_rel (
              todo_id INT NOT NULL,
              cat_id INT NOT NULL)')
  # db.execute('')
      
end

def populate_tables(db)
  db.execute('INSERT INTO todos (name, notes) VALUES ("Add toggle complete", "Do this last")')
  db.execute('INSERT INTO todos (name, notes) VALUES ("Add Edit functionality test", "if this is added stuff worked test")')
  db.execute('INSERT INTO todos (name, notes) VALUES ("Add categories", "Searchable categories")')

  db.execute('INSERT INTO categories (name) VALUES ("admin")')
  db.execute('INSERT INTO categories (name) VALUES ("development")')
  db.execute('INSERT INTO categories (name) VALUES ("purchases")')

  db.execute('INSERT INTO todo_cat_rel (todo_id, cat_id) VALUES (1, 2)')
  db.execute('INSERT INTO todo_cat_rel (todo_id, cat_id) VALUES (2, 2)')
  db.execute('INSERT INTO todo_cat_rel (todo_id, cat_id) VALUES (3, 2)')
  db.execute('INSERT INTO todo_cat_rel (todo_id, cat_id) VALUES (1, 1)')
end

seed!(db)