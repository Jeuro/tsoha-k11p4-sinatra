require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'

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
  
  property :id, Serial
  property :otsikko, String
  property :luomispvm, DateTime
  property :deadline, DateTime
  property :paikkakunta, String
  property :ala, String
  property :tiedot, Text
  
  has n, :hakemukset, 'Hakemus'
end

DataMapper.auto_upgrade!