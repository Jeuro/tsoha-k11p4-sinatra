require 'rubygems'
require 'dm-core'
require 'dm-migrations'

class Hakemus
  include DataMapper::Resource
  
  storage_names[:default] = "hakemukset"
  
  property :id, Serial
  property :luontipvm, DateTime
  property :sisalto, Text
  
  belongs_to :kayttaja, :key => true
  belongs_to :ilmoitus, :key => true
end

Hakemus.auto_migrate! unless Hakemus.storage_exists?
