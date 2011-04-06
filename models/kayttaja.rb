require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'

DataMapper.setup(:default, 'sqlite:///tsoha.db')

class Kayttaja
  include DataMapper::Resource
  
  property :id, Serial
  property :nimi, String, :required => true
  property :hetu, String, :required => true
  property :salasana, String, :required => true
  property :osoite, String, :required => true
  property :puhelin, String
  property :email, String, :required => true
  
  has n, :hakemukset, 'Hakemus'
end

Kayttaja.auto_migrate! unless Kayttaja.storage_exists?
