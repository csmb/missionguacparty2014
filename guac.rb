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
  partier = Partier.new(params)
  if partier.save
    Pony.mail to: partier.email,
            from: "MGP <missionguacparty@gmail.com>",
            subject: "Guacamole!",
            body: welcome_email.result(binding)
    redirect '/success'
  else
    redirect '/'
  end
end

get '/success' do
  erb :success, layout: :application
end
