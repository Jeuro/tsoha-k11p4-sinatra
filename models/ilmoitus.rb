require 'rubygems'
require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, 'sqlite:///tsoha.db')

class Ilmoitus
  include DataMapper::Resource
  
  property :id, Serial
  property :luomispvm, DateTime
  property :deadline, DateTime
  property :paikkakunta, String
  property :ala, String
  property :tiedot, Text
  
  has n, :hakemukset, 'Hakemus'
end

Ilmoitus.auto_migrate! unless Ilmoitus.storage_exists?