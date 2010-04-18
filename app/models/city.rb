class City
  include MongoMapper::Document
  
  key :aemet_key, String
  key :name, String
  key :region, Mongo::ObjectID
  key :general_prediction_success, Float
  
  many :days
  belongs_to :region
  
  class << self
    def best
      City.all(:order => 'general_prediction_success DESC', :limit => 5)
    end
    
    def worst
      City.all(:order => 'general_prediction_success ASC', :limit => 5)
    end
  end  
  
  def get_day_from_today(jump)
    self.days.all.select { |d| d.date == (Date.today + jump.days) }
  end
  
  
end
