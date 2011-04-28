# encoding: utf-8

require 'rubygems'
require 'sinatra'
require 'erubis'
require 'rack-flash'

require './config/init'
require './models'
require 'digest/md5'

module Helpers	
	def logged_in?
		not session[:kayttaja].nil?
	end	
end

class Yleinen < Sinatra::Base	
	enable :sessions
	use Rack::Flash
	
	helpers Helpers		
	
	set :public, File.dirname(__FILE__) + "/public"
	set :erubis, :escape_html => true
	
	get '/' do    
		erubis :index
	end
	
	get '/register' do
		erubis :register
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
		
		unless params[:salasana].length > 4
			flash[:error] = "Salasanassa oltava vähintään 5 merkkiä."
			redirect '/register'
		end
		
		unless params[:salasana] == params[:salasana2]
			flash[:error] = "Salasanat eivät täsmää."
			redirect '/register'
		end
		
		if @kayttaja.save
			flash[:notice] = "Rekisteröinti onnistui!"
			redirect '/'
		else
			@errors = @kayttaja.errors			
			erubis :register
		end	
	end
	
	get '/login' do
		erubis :login
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
	
	get '/paikkahaku' do
		erubis :paikkahaku
	end
		
	get '/hakutulokset' do
		@ilmoitukset = Ilmoitus.all
		
		unless params[:kunta].empty?
			@ilmoitukset = @ilmoitukset.all(:conditions => ['UPPER(paikkakunta) LIKE ?', "%#{params[:kunta]}%".upcase])
		end
		
		unless params[:ala].empty?
			@ilmoitukset = @ilmoitukset.all(:conditions => ['UPPER(ala) LIKE ?', "%#{params[:ala]}%".upcase])
		end
		
		unless params[:sana].empty?
			@ilmoitukset = @ilmoitukset.all(:conditions => ['UPPER(tiedot) LIKE ?', "%#{params[:sana]}%".upcase]) + 
							@ilmoitukset.all(:conditions => ['UPPER(otsikko) LIKE ?', "%#{params[:sana]}%".upcase])
		end
		
		erubis :hakutulokset
	end
	
	get '/ilmoitus/:id' do
		@ilmoitus = Ilmoitus.get(params[:id])
		erubis :ilmoitus
	end		
	
end

class Kirjautunut < Sinatra::Base
	helpers Helpers		

	set :erubis, :escape_html => true
	
	before do
		unless logged_in?
			halt "Sinun on <a href='/login'>kirjauduttava sisään</a>."
		end
		
		@kayttaja = Kayttaja.first(:id => session[:kayttaja])	
	end
	
	get '/logout' do
		session[:kayttaja] = nil
		redirect '/'
	end
	
	get '/oma_sivu' do			
		erubis :oma_sivu		
	end
	
	get '/kayttajatiedot' do		
		erubis :kayttajatiedot
	end
	
	post '/kayttajatiedot' do		
		if @kayttaja.update(:nimi => params[:nimi], :osoite => params[:osoite], :puhelin => params[:puhelin], :email => params[:email])
			flash[:notice] = "Tiedot päivitetty."
			redirect '/kayttajatiedot'
		else
			flash[:error] = "Tietojen päivitys epäonnistui."
			redirect '/kayttajatiedot'
		end					
	end
	
	get '/hakemus/:hakemus_id' do		
		@hakemus = @kayttaja.hakemukset.first(:id => params[:hakemus_id])
		
		erubis :hakemus
	end	
	
	get '/hakemuksen_luonti/:ilmoitus_id' do				
		erubis :hakemuksen_luonti		
	end
	
	post '/hakemuksen_luonti/:ilmoitus_id' do
		@hakemus = Hakemus.create
		@hakemus.sisalto = params[:hakemus]
		@hakemus.kayttaja = @kayttaja
		@hakemus.ilmoitus = Ilmoitus.first(:id => params[:ilmoitus_id])		
		
		if @hakemus.save	
			redirect '/oma_sivu'
		else
			flash[:error] = "Et voi lähettää tyhjää hakemusta."
			redirect "/hakemuksen_luonti/#{params[:ilmoitus_id]}"
		end
	end
end

class Tsoha < Sinatra::Base	
	use Yleinen
	use Kirjautunut	
end