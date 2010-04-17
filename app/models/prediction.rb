class Prediction
  include MongoMapper::EmbeddedDocument
  
  key :max, Float
  key :min, Float
  key :pop, Float 
  
  belongs_to :day  
end
