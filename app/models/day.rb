class Day
  include MongoMapper::Document
  
  key :date, Date
  
  many :observations
  many :predictions

  def get_prediction_from_day(jump)
    self.predictions.select { |p| p.date == (self.date + jump.days) }
  end

  def get_observation_from_day(jump)
    self.observations.select { |o| o.date == (self.date + jump.days) }
  end

end
