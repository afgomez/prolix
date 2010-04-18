class CitiesController < ApplicationController
  
  def index    
    redirect_to(city_path(params[:id]))
  end
  
  def show
    @city = City.find_by_name(params[:id])
  end

end
