class Prediction
  include MongoMapper::EmbeddedDocument
  
  key :max, Float
  key :min, Float
  key :pop, Float 
  key :date, Date

  belongs_to :day
end
