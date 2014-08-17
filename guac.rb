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
  property :name, Text
  property :email, Text
  property :item, Enum[:guac, :beer, :other], default :new
  property :created_at, DateTime
  property :updated_at, DateTime
end
DataMapper.finalize.auto_upgrade!


helpers do
  include Rack::Utils
end

get '/' do
  erb :home
end

post '/' do
  p = Partiers.new
  p.name = "name"
  p.email = params[:email]
  p.item = params[:item]

  p.created_at = Time.now
  p.updated_at = Time.now
  if p.save
    redirect '/success'
  else
    redirect '/', :error => 'Damn'
  end
  # redirect '/', :notice => 'Welcome to the guacamole life.'
end

get '/success' do
  erb :success
end
