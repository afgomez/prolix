class Aemet
  include MongoMapper::Document
  
  key :prediction_tmax_success, Float
  key :prediction_tmin_success, Float
  key :prediction_pop_success, Float
  key :date, Date



  def prediction_success
    (self.prediction_tmax_success + self.prediction_tmin_success + prediction_pop_success)/3
  end

  class << self
    
    def for_graph      
      require 'enumerator' 
      Aemet.all(:limit => 15).to_enum(:each_with_index).collect { |a,i| [i,a.prediction_success] }
    end
  end  
  
end
