require 'rubygems'
require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, 'sqlite:///tsoha.db')

class Hakemus
  include DataMapper::Resource
  
  storage_names[:default] = "hakemukset"
  
  property :id, Serial
  property :luontipvm, DateTime
  property :sisalto, Text
  
  belongs_to :kayttaja
end

Hakemus.auto_migrate! unless Hakemus.storage_exists?
