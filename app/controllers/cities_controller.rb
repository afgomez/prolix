class CitiesController < ApplicationController
  
  
  def index
    # Datos de prueba para la maqueta...
    cities = %w{Alicante Valencia Zaragoza León Pamplona Cáceres Badajoz Oviedo Teruel Barcelona}.sort
    @query = params[:query].downcase
    @cities = @query.nil? ? cities : cities.map { |city| city if city.downcase.include? @query }.compact
  end

  def show
    @city = ''
  end

end
