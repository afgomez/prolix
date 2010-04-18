class CitiesController < ApplicationController
  
  def index
    # Datos de prueba para la maqueta...
    cities = City.all
    @query = params[:query].downcase
    @cities = @query.nil? ? cities : cities.map { |city| city if city.downcase.include? @query }.compact
  end
  
  def show
    @city = City.find_by_name(params[:id])
  end

end
