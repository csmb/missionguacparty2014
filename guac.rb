require 'sinatra'
require 'sinatra/flash'
require 'data_mapper'
require 'dm-postgres-adapter'
require 'dm-timestamps'
require 'dm-core'
require 'pg'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/database.db")
class Partiers
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :email, String
  property :guac, Boolean, default: false
  property :beer, Boolean, default: false
  property :other, Boolean, default: false
  property :created_at, DateTime
  property :updated_at, DateTime
end
DataMapper.finalize.auto_upgrade!

helpers do
  include Rack::Utils
end

set :public_folder, 'public'

get '/' do
  erb :home, layout: :application
end

post '/' do
  p = Partiers.new
  p.name = params[:name]
  p.email = params[:email]
  if params[:guac]
    p.guac = true
  end
  if params[:beer]
  p.beer = true
  end
  if params[:other]
    p.other = true
  end
  p.created_at = Time.now
  p.updated_at = Time.now
  if p.save
    redirect '/success'
  else
    redirect '/', :error => 'Damn'
  end
end

get '/success' do
  erb :success, layout: :application
end
