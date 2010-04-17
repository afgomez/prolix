class Observation
  include MongoMapper::EmbeddedDocument
  
  key :hour, Integer 
  key :min, Float
  key :max, Float
  key :pop, Float

  belongs_to :day  
end
