require 'bcrypt'

get('/register') do
    slim(:register)
end

post('/register') do
    username = params[:username]
    password, confirm_password = params[:password], params[:pwd_confirm]
    admin = (params[:admin] == "true" ? "1" : "0")

    username_check = db.execute('SELECT user_id FROM users WHERE username=?', username.downcase)
    if username_check.empty?
        if password == confirm_password
            pwd_digest = BCrypt::Password.create(password)
            db.execute('INSERT INTO users (username, pwd_digest, admin) VALUES (?, ?, ?)', [username.downcase, pwd_digest, admin])
            redirect('/')
        else
            session[:pwd_fail] = "Passwords must match."
            redirect('/register')
        end
    else
        session[:username_fail] = "Username already taken"
        redirect('/register')
    end
end


post('/login') do
    pwd, username = params[:pwd], params[:username]
    if !user = db.execute('SELECT * FROM users WHERE username=?', username.downcase).first
        flash[:login] = "Login unsucessful: username does not exist"
        redirect('/')
    end
    p user

    if BCrypt::Password.new(user['pwd_digest']) == pwd
        session[:uid] = user['user_id']
        if user['admin'] == 1
            session[:admin] = true
        end
        flash[:login] = "Login successful"
    else
        flash[:login] = "Login unsucessful: Incorrect password"
    end
    redirect('/')
end

post('/logout') do
    session.clear
    redirect('/')
end