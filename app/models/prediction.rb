class Prediction
  include MongoMapper::EmbeddedDocument
  
  key :max, Float
  key :min, Float
  key :pop, Float
  key :score_max, Float
  key :score_min, Float
  key :score_pop, Float
  key :date, Date
  key :day_id, Mongo::ObjectID

  belongs_to :day
  
  def score
    (self.score_max + self.score_min + self.score_pop)/3;
  end

  def evaluate observation

    if observation.pop > 0
      self.score_pop = pop
    else
      self.score_pop = 1 - pop
    end

    if observation.max > self.max
      self.score_max = 1 - ((observation.max  - self.max)/ (self.max - self.min))
    else
      self.score_max = 1
    end

    if observation.min < self.min
      self.score_min = 1 - ((self.min - observation.min)/ (self.max - self.min))
    else
      self.score_min = 1
    end

    puts "Date #{self.day.date} Score POP #{self.score_pop}\tScore MIN #{self.score_min}\tScore MAX #{self.score_max}"
  end
end
