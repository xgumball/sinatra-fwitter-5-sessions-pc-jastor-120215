require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
  end

  get '/' do
    @tweets = Tweet.all
    @users = User.all
    erb :index
  end

  get '/tweet' do
    erb :tweet
  end

  post '/tweet' do
    user = User.find_by(:username => params[:username])
    tweet = Tweet.new(:user => user, :status => params[:status])
    tweet.save
    redirect '/'
  end

  get '/users' do
    @users = User.all
    erb :users
  end

  post '/sign-up' do 
    @user = User.new(:username => params[:username], :email => params[:email])
    @user.save
    redirect '/'
  end
end
