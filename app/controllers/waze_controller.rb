class WazeController < ApplicationController
  require 'httparty'
  require 'json'

  def index
    data = waze_params
    #puts params[:fx]
    puts data[:url]
    puts data[:fx]
    puts data[:fy]
    puts data[:tx]
    puts data[:ty]

    url = data[:url]
    fx = data[:fx]
    fy = data[:fy]
    tx = data[:tx]
    ty = data[:ty]

    #tx = "-70.61224222183228"
    #ty = "-70.61224222183228"

    #url = "routingRequest"

    wazeBase = "https://www.waze.com/"
    if url == "routingRequest"
      puts "Entre al IF"
    waze_url = wazeBase+"row-RoutingManager/"+url+"?from=x%3A"+fx+"+y%3A"+fy+"&to=x%3A"+tx+"+y%3A"+ty+"&at=0&returnJSON=true&returnGeometries=true&returnInstructions=true&timeout=60000&nPaths=1&options=AVOID_TRAILS%3At "
      puts waze_url
      response = HTTParty.get(waze_url)
      puts response.body

      render json: response.body

      #route = JSON.parse(response.body)
      #@waze = route
      #puts route
      #respond_with route
      #route.first.each do |coord|
      #  puts coord
      #end
    end

  end


  private

  def waze_params
    params.permit(:url, :fx, :fy, :tx, :ty)
  end

end