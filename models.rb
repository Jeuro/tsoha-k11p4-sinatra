require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'dm-timestamps'

class Kayttaja
  include DataMapper::Resource
  
  storage_names[:default] = "kayttajat"
  
  property :id, Serial
  property :nimi, String, :required => true
  property :tunnus, String, :required => true
  property :salasana, String, :required => true
  property :salt, String, :required => true  
  property :osoite, String, :required => true
  property :puhelin, String
  property :email, String, :required => true, :format => :email_address
  
  has n, :hakemukset, 'Hakemus'
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