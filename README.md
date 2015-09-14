# Sinatra Fwitter 5 -  Sessions

## Objectives

1. Understand the difference between authentication and authorization
2. Implement sessions into our Sinatra applications
3. Use session data to change content based on whether or not a user is logged in.

## Overview

Two of the most important aspects of social media applications are authentication and authorization. In a nutshell, authentication means having a user identify themselves in your application, while authorization determines what a user is able to do. For example, anyone can view other people's Tweets on Twitter, but only logged in users can post new content. 

Today, we'll be updating our Fwitter application so that only logged in users can post content, and new tweets will automatically be associated with the logged in user.

## Instructions

### Setup

Fork, clone, and run `bundle install` and `rake db:migrate` to get started!

Notice that we're now using a file called `layout.erb`. This is some Sinatra magic so we don't have to write our HTML shell every time. This file will get rendered on every get request. When `yield` is called, Sinatra will render whichever template we instructed it to (`index.erb`, `tweet.erb`, etc.) Afterwards, it will come back and render the rest of the layout. This means we can write some code only once and have it appear on every page. 

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
  	 if user
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
  	 if user
  	 	session[:user_id] = user.id
  	 	redirect "/"
  	 else
  	 	redirect "/signup"
  	 end
  end
```

Awesome job - we're now storing the current user's id in our session! Let's see how we can use that to update how our user is tweeting. 

### Part 3: Adding Authorization

Next, let's add some logic to our application to determine when a user can view certain items. We'll set up our application so that any user can view tweets, but you must be logged in to post new content. Let's update our "/tweet" route so that non-logged in users get redirected to the "/login" route. In pseudo-code, this would look something like this:

```ruby
  get '/tweet' do
    # if there's a session[:user_id]
    	# erb :tweet
    # else
    #   redirect to the login page
    # end    
  end

```

Not too hard, right? We can write this in actual Ruby code as follows: 

```ruby
  get '/tweet' do
    if session[:user_id] #returns nil if there isn't one
      erb :tweet
    else
      redirect "/login"
    end
  end

```

Awesome! Next, let's update our new tweet form in `tweet.erb` so that a user no longer enters their username.

```erb
<h2>Add a tweet</h2>
<form action="/tweet" method="POST">
  <p>Status: <input type="text" name="status"></p>
  <input class="btn btn-primary" type="submit">
</form>
```

We can now update our `post "tweet"` action to find the user by the session id instead of what's in params. 

```ruby
  post '/tweet' do
    user = User.find_by(:user_id => session[:user_id])
    tweet = Tweet.new(:user => user, :status => params[:status])
    tweet.save
    redirect '/'
  end
```

Awesome! Now, new tweets will be automatically associated with a logged in user!

### Part 4: Ending a Session

This is great, but what if a user wants to logout? For that, we simply need to clear the session data. Build out a new route in your controller for "/logout".

```ruby
  get '/logout' do
  end
```

Inside of this request, we'll destroy any data associated with the session by calling the `destroy` method.

```ruby
  get '/logout' do
    session.destroy
    redirect '/login'
  end
```

This will simply clear the session hash and redirect us to the "/login" page. Awesome!

### Part 5: Building a Nav Bar

Now for some extra fun: let's build out a nav bar for our site. If a user is logged in, it will show their username and give them a link to logout or post a new tweet. If they're not logged in, they'll see links to either login or signup.

We'll build this out in `layout.erb`, so that it will show up in every page. To make things easier and make our code read better, we'll setup some helper methods in our application controller. We can set these up using a block called "helpers". First, we'll add a method called `logged_in?` which will return true if there is a session[:user_id]. 

```ruby
  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
  end
  
  helpers do
    def logged_in?
      session[:user_id]
    end
  end
```

Next, let's add a method called `current_user` which loads that user based on the session[:user_id]

```ruby
  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
  end
  
  helpers do
    def logged_in?
      session[:user_id]
    end
    
    def current_user
      User.find(session[:user_id])
    end
  end
```

Now, let's use these helper methods to build out our nav bar. If the user is logged in, let's display the current user's username and show them a link to log out.

```erb
<body>
	<nav>
      <ul>
        <% if logged_in? %>
        	<li>Welcome, <%= current_user.username %></li>
        	<li><a href="/tweet">Post a Tweet!</a></li>
        	<li><a href="/logout">Logout</a></li>
        <% end %>
      </ul>
    </nav>
	<div class="container">
	
	  <h1>Welcome to Fwitter!</h1>
	  
	  <%= yield %> 	  
</body>
``` 
If there's no current user, we'll show them a link to either sign up or login.

```erb
<body>
	<nav>
      <ul>
        <% if logged_in? %>
        	<li>Welcome, <%= current_user.username %></li>
        	<li><a href="/tweet">Post a Tweet!</a></li>
        	<li><a href="/logout">Logout</a></li>
        <% else %>
        	<li><a href="/login">Login</a></li>
        	<li><a href="/signup">Sign Up</a></li>
        <% end %>
      </ul>
    </nav>
	<div class="container">
	
	  <h1>Welcome to Fwitter!</h1>
	  
	  <%= yield %> 	  
</body>
``` 

Awesome! We've now used a session to create a different user experience for people who are logged in or not!

