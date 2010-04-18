class HomeController < ApplicationController

  def index
    @aemet = Aemet.first
  end
    
end
