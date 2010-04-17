class Region
  include MongoMapper::Document
  
  key :name, String
  key :aemet_key, String
  
  many :cities
end
