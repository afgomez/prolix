class Aemet
  include MongoMapper::Document
  
  key :prediction_tmax_success, Float
  key :prediction_tmin_success, Float
  key :prediction_pop_success, Float
  key :date, Date
  
  class << self

    def general_prediction_success
      50
    end
    
    def for_graph      
      require 'enumerator' 
      Aemet.all(:limit => 15).to_enum(:each_with_index).collect { |a,i| [i,a.prediction_success] }
    end
  end  
  
end
