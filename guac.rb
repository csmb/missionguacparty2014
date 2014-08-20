require 'sinatra'
require 'sinatra/flash'
require 'data_mapper'
require 'dm-postgres-adapter'
require 'dm-timestamps'
require 'dm-core'
require 'pg'
require 'pony'

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
  Pony.mail :to => params[:email],
            :from => "missionguacparty@gmail.com",
            :subject => "See ya at the party #{params[:name]}!",
            :body => erb(:email),
            :via_options => {
              :address              => 'smtp.gmail.com',
              :port                 => '587',
              :enable_starttls_auto => true,
              :user_name            => 'missionguacparty',
              :password             => ENV['MGP_PASS'],
              :authentication       => :plain, 
              :domain               => "localhost.localdomain" 
            }
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
