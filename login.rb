post('/login') do
    pass = params[:pass]
    if pass == "AdminPassword1234"
        session[:admin] = true
        flash[:login] = "Info: Login successful"
    else
        flash[:login] = "Info: Login unsucessful"
    end
    redirect('/')
end

post('/logout') do
    session[:admin] = false
    flash[:login] = "Info: Logged out"
    redirect('/')
end