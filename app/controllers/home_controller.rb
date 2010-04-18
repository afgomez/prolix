class HomeController < ApplicationController

  def index
    @aemets = Aemet.all.select {|aemet| aemet.date >= (Date.today - 7)}
    @average_performance = 0
    @aemets.each do |aemet| @average_performance += aemet.prediction_success end
    @average_performance /= @aemets.length
  end
    
end
