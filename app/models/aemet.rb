class Aemet
  include MongoMapper::Document
  
  key :prediction_success, Float
  
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
