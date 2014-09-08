require 'sinatra'
require 'pg'

require_relative './email'
require_relative './models'

welcome_email = ERB.new(IO.read('./views/emails/welcome.erb'))

helpers do
  include Rack::Utils
end

set :public_folder, 'public'

get '/' do
  erb :home, layout: :application
end

post '/' do
  p = Partier.new
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
  Pony.mail to: p.email,
            from: "MGP <missionguacparty@gmail.com>",
            subject: "Guacamole!",
            body: welcome_email.result(binding)
  if p.save
    redirect '/success'
  else
    redirect '/'
  end
end

get '/success' do
  erb :success, layout: :application
end
