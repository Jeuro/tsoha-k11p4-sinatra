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
	
	helpers do		
		def logged_in?
			not session[:kayttaja].nil?
		end
	end
	
	get '/' do    
		erb :index
	end
	
	get '/register' do
		erb :register
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
			flash[:notice] = "Rekisteröinti onnistui!"
			redirect '/'
		else
			@errors = @kayttaja.errors
			
			erb :register
		end	
	end
  
	get '/login' do
		erb :login
	end
	
	post '/login' do
		kayttaja = Kayttaja.tunnista(params[:tunnus])
		
		if kayttaja.nil?
			flash[:error] = "Anna oikea tunnus ja salasana"
			redirect '/login'
		else
			if kayttaja.tarkista_salasana(params[:salasana])
				session[:kayttaja] = kayttaja.id
				redirect '/oma_sivu'
			else
				flash[:error] = "Anna oikea tunnus ja salasana"
				redirect '/login'
			end			
		end
	end	
	
	get '/logout' do
		session[:kayttaja] = nil
		redirect '/'
	end
	
	get '/oma_sivu' do
		@kayttaja = Kayttaja.first(:id => session[:kayttaja])
		
		if logged_in?
			erb :oma_sivu
		else			
			redirect '/login'
		end
	end
	
	get '/kayttajatiedot' do
		@kayttaja = Kayttaja.first(:id => session[:kayttaja])
		erb :kayttajatiedot
	end
	
	post '/kayttajatiedot' do		
		kayttaja = Kayttaja.first(:id => session[:kayttaja])
		
		if kayttaja.update(:nimi => params[:nimi], :osoite => params[:osoite], :puhelin => params[:puhelin], :email => params[:email])
			flash[:notice] = "Tiedot päivitetty."
			redirect '/kayttajatiedot'
		else
			flash[:error] = "Tietojen päivitys epäonnistui."
			redirect '/kayttajatiedot'
		end
		
						
	end
	
	get '/hakemus/:hakemus_id' do
		@kayttaja = Kayttaja.first(:id => session[:kayttaja])
		@hakemus = @kayttaja.hakemukset.first(:id => params[:hakemus_id])
		
		erb :hakemus
	end
	
	get '/hakemuksen_luonti/:ilmoitus_id' do
		@kayttaja = Kayttaja.first(:id => session[:kayttaja])
		if logged_in?
			erb :hakemuksen_luonti
		end
	end
	
	post '/hakemuksen_luonti/:ilmoitus_id' do
		@hakemus = Hakemus.create
		@hakemus.sisalto = params[:hakemus]
		@hakemus.kayttaja = Kayttaja.first(:id => session[:kayttaja])
		@hakemus.ilmoitus = Ilmoitus.first(:id => params[:ilmoitus_id])		
		
		if @hakemus.save	
			redirect '/oma_sivu'
		else
			flash[:error] = "Et voi lähettää tyhjää hakemusta."
			redirect "/hakemuksen_luonti/#{params[:ilmoitus_id]}"
		end
	end
	
	get '/paikkahaku' do
		erb :paikkahaku
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

	run! if app_file == $0
end
