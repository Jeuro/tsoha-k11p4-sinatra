# encoding: utf-8

require 'rubygems'
require 'sinatra'
require 'erb'
require './config/init'
require './models'


class Tsoha < Sinatra::Base

	enable :sessions
	set :public, File.dirname(__FILE__) + "/public"
	
	get '/' do    
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
	
	get '/haku' do
		if params[:sana]==""
			@ilmoitukset = Ilmoitus.all(:paikkakunta.like => params[:kunta])
		else
			@ilmoitukset = Ilmoitus.all(:tiedot.like => "%#{params[:sana]}%") + Ilmoitus.all(:otsikko.like => "%#{params[:sana]}%") + Ilmoitus.all(:paikkakunta.like => params[:kunta])
		end
		
		erb :haku
	end
	
	get '/ilmoitus/:id' do
		@ilmoitus = Ilmoitus.get(params[:id])
		erb :ilmoitus
	end

#	get '/sessioon/:arvo' do
#		session[:muuttuja] = params[:arvo]
#		redirect '/'
#	end

	run! if app_file == $0
end