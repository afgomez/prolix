class Observation
  include MongoMapper::EmbeddedDocument
  
  key :hour, Integer 
  key :temp, Float

  belongs_to :day  
end
