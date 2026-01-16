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


###################### FIXA LOGIN ####################
post('/login') do
    pwd = params[:pwd]
    if pwd == "AdminPassword1234"
        session[:user_id] = true #ÄNDRA SEN
        session[:admin] = true
        flash[:login] = "Info: Login successful"
    else
        flash[:login] = "Info: Login unsucessful"
    end
    redirect('/')
end

post('/logout') do
    session.clear
    redirect('/')
end