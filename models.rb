# encoding: utf-8

require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'dm-timestamps'

class Kayttaja
	include DataMapper::Resource
  
	storage_names[:default] = "kayttajat"

	property :id, Serial
	property :nimi, String, :required => true, 
	:messages => {
		:presence  => 'Nimi on pakollinen.'
	}
	property :tunnus, String, :required => true,
	:messages => {
		:presence  => 'Käyttäjätunnus on pakollinen.'
	}
	property :salasana, String, :required => true
	property :salt, String, :required => true  
	property :osoite, String, :required => true,
	:messages => {
		:presence  => 'Osoite on pakollinen.'
	}
	property :puhelin, String
	property :email, String, :required => true, :format => :email_address,
	:messages => {
		:presence  => 'Email on pakollinen.'
	}
	has n, :hakemukset, 'Hakemus'
  
	def self.tunnista(tunnus)		
		self.first(:tunnus => tunnus)
	end
	
	def tarkista_salasana(salasana)
		if @salasana == Digest::MD5.hexdigest(salasana + @salt)
			return true
		else
			return false
		end
	end
end

class Hakemus
	include DataMapper::Resource
  
	storage_names[:default] = "hakemukset"
  
	property :id, Serial
	property :luontipvm, DateTime
	property :sisalto, Text
  
	belongs_to :kayttaja, :key => true
	belongs_to :ilmoitus, :key => true
end

class Ilmoitus
	include DataMapper::Resource
  
	storage_names[:default] = "ilmoitukset"
  
	property :id, Serial
	property :otsikko, String
	property :created_at, DateTime
	property :deadline, DateTime
	property :paikkakunta, String
	property :ala, String
	property :tiedot, Text
  
	has n, :hakemukset, 'Hakemus'
end

DataMapper.finalize
DataMapper.auto_upgrade!