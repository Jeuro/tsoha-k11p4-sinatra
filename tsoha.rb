# encoding: utf-8

require 'rubygems'
require 'sinatra'
require 'erb'
require 'rack-flash'

require './config/init'
require './models'
require 'digest/md5'


class Tsoha < Sinatra::Base	
	enable :sessions
	use Rack::Flash
	
	set :public, File.dirname(__FILE__) + "/public"
	
	get '/' do    
		erb :index
	end
  
	get '/login' do
		erb :login
	end
	
	get '/paikkahaku' do
		erb :paikkahaku
	end
  
	get '/register' do
		erb :register
	end
	
	get '/hakutulokset' do
		if params[:sana] == ""
			@ilmoitukset = Ilmoitus.all(:conditions => ['UPPER(paikkakunta) LIKE ?', "%#{params[:kunta]}%".upcase])
		else
			@ilmoitukset = Ilmoitus.all(:conditions => ['UPPER(tiedot) LIKE ?', "%#{params[:sana]}%".upcase]) + Ilmoitus.all(:conditions => ['UPPER(otsikko) LIKE ?', "%#{params[:sana]}%".upcase]) & Ilmoitus.all(:conditions => ['UPPER(paikkakunta) LIKE ?', "%#{params[:kunta]}%".upcase])
		end
		
		erb :hakutulokset
	end
	
	get '/ilmoitus/:id' do
		@ilmoitus = Ilmoitus.get(params[:id])
		erb :ilmoitus
	end
	
	get '/hakemuksen_luonti' do
		erb :hakemuksen_luonti
	end
	
	post '/register' do 		
		@kayttaja = Kayttaja.create
		@kayttaja.nimi = params[:nimi]
		@kayttaja.osoite = params[:osoite]
		@kayttaja.puhelin = params[:puhelin]
		@kayttaja.email = params[:email]
		@kayttaja.tunnus = params[:tunnus]
		@kayttaja.salt = (0...16).map{65.+(rand(25)).chr}.join
		@kayttaja.salasana = Digest::MD5.hexdigest(params[:salasana] + @kayttaja.salt)
		
		if @kayttaja.save
			erb :rekisterointi_onnistui		
		else
			@errors = @kayttaja.errors
			
			erb :register
		end	

	end

#	get '/sessioon/:arvo' do
#		session[:muuttuja] = params[:arvo]
#		redirect '/'
#	end

	run! if app_file == $0
end