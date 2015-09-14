# Sinatra Fwitter 5 -  Sessions

## Outline
1. Explain the difference between authentication and authorization. The most basic form of authentication is simply asking for a username.
2. Enable sessions and set a session secret in the application controller.
3. Create a template called `login.erb` with a form asking for a username. 
4. Update the application controller - upon submission of the form, find the user by username and set the session[:user_id] to that user's id. If no user is found, redirect to signup.
5. Update the new tweet form so that the user is set by the current user in the session id, instead of asking for a user's username. 
6. Create a `/logout` route that destroys the session. 
7. Add logic so that the new tweet form is only displayed to logged_in users.
8. Add helper methods: `current_user` to return the user based on session[:id] and `logged_in?` to return true or false based on the presence of a session[:user_id]

## Objectives

1. Understand the difference between authentication and authorization
2. Implement sessions into our Sinatra applications
3. Use session data to change content based on whether or not a user is logged in.

## Overview

Two of the most important aspects of social media applications are authentication and authorization. In a nutshell, authentication means having a user identify themselves in your application, while authorization determines what privelages a user has. For example, anyone can view other people's Tweets on Twitter, but only logged in users can post new content. 

Today, we'll be updating our Fwitter application so that only logged in users can post content, and new tweets will automatically be associated with the logged in user.

## Instructions

Fork, clone, and run `bundle install` and `rake db:migrate` to get started!

### Part 1: Enabling Sessions

Sessions are disabled in Sinatra by default, so we need to enable them before doing anything else. In the configure block of your application controller, enable sessions and add a session secret.

```ruby
  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "fwitter_secret"
  end

```

### Part 2: The Login Form

Notice that we're now using a file called `layout.erb`. This is some Sinatra magic so we don't have to write our HTML shell every time. This file will get rendered on every get request. When `yield` is called, Sinatra will render whichever template we instructed it to (`index.erb`, `tweet.erb`, etc.) Afterwards, it will come back and render the rest of the layout. This means we can write some code only once and have it appear on every page. 

We need to build out a form where a user can log in. The most basic form of authentication is simply asking for a username (we'll pretend that everyone is honest and only types in their username.) Create a new file, `login.erb` and build a form with an input for username.

```erb
<h1>Login to Fwitter!</h1>
<form method="post" action="/login">
  <input type="text" name="username" placeholder="Username:">
  <input type="submit">
</form>
```

Build on a controller action to render the form - the route should be `get '/login'`.

```ruby
  get '/login' do
    erb :login
  end

```

### Logging In

Next, let's build out what happens when the user presses submit on out form. We gave our login form a method of "post" and an action of "/login" - let's build that into our controller.

```ruby
  get '/login' do
    erb :login
  end
  
  post '/login' do
    'hello login request'
  end

```

Submit your form and you should see "hello login request". Awesome! Next, let's see what `params` looks like.

```ruby
  get '/login' do
    erb :login
  end
  
  post '/login' do
  	 puts params
    'hello login request'
  end

```

In your terminal, you should see something like this: 

```bash
{"username" => "the_username_i_typed_in"}
```

Let's use that information to find the user in our database. 

```ruby
  post '/login' do
  	 user = User.find_by(:username => params[:username])
    'hello login request'
  end

```

Here, we'll have two different branches. Either we'll find a user in our database or we won't. If `user` is not equal to nil, we'll log the user in. Othewise, we'll send them to the signup page. In psuedo-code, this looks something like this. 

```ruby
  post '/login' do
  	 user = User.find_by(:username => params[:username])
  	 if user != nil
  	 	#log the user in
  	 else
  	 	#send them to sign up!
  	 end
  end

```

Because any user that's found is a "truthy" value, we can also write this as:

```ruby
  post '/login' do
  	 user = User.find_by(:username => params[:username])
  	 if user
  	 	#log the user in
  	 else
  	 	#send them to sign up!
  	 end
  end

```

Let's handle our else case first. If we don't find a user, we'll simply redirect them to the "/signup" route.

```ruby
  post '/login' do
  	 user = User.find_by(:username => params[:username])
  	 if user != nil
  	 	#log the user in
  	 else
  	 	redirect "/signup"
  	 end
  end
```
Awesome! If we do find that user, we need to first set the `session[:user_id]` to be that user's id, then redirect them to the home page. 

```ruby
  post '/login' do
  	 user = User.find_by(:username => params[:username])
  	 if user != nil
  	 	session[:user_id] = user.id
  	 	redirect "/"
  	 else
  	 	redirect "/signup"
  	 end
  end
```

Awesome job - we're now storing that 

## Resources

* [Stack Exchange](http://www.stackexchange.com) - [Some Question on Stack Exchange](http://www.stackexchange.com/questions/123)