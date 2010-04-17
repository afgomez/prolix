class City
  include MongoMapper::Document
  
  key :aemet_key, String
  key :name
  key :region, Mongo::ObjectID
  
  many :days
  belongs_to :region
end
