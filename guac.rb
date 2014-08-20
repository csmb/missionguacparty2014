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
  property :bringing, Flag[:guac, :beer, :other]
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
  p.bringing = []
  if params[:guac]
    p.bringing = [:guac]
  end
  if params[:beer]
    p.bringing += [:beer]
  end
  if params[:other]
    p.bringing += [:other]
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
