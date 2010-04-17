class Day
  include MongoMapper::Document
  
  key :date, Date
  
  many :observations
  many :predictions
end
