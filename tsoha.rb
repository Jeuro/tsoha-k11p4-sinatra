# encoding: utf-8

require 'rubygems'
require 'sinatra'
require 'erb'

require './config/init'

require './models/kayttaja'
require './models/hakemus'
require './models/ilmoitus'



class Tsoha < Sinatra::Base

#	enable :sessions
#	set :public, File.dirname(__FILE__) + "/public"
	
	get '/' do    
#	@sessiosta_muuttujaan = session[:muuttuja]
#   @testmodelin_arvot = User.all
#	@esimerkkimuuttuja = "tama on muuttuja"
		erb :index
	end
  
	get '/login' do
		erb :login
	end
	
	get '/paikat' do
		erb :paikat
	end
  
	get '/register' do
		erb :register
	end

#	get '/sessioon/:arvo' do
#		session[:muuttuja] = params[:arvo]
#		redirect '/'
#	end
	run! if app_file == $0
end