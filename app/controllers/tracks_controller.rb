class TracksController < ApplicationController

  def index

  end

  def new

  end

  def create
    uploaded_file = track_params[:file]

    gpx_file = GPX::File.new uploaded_file.tempfile
    @points = gpx_file.points.map {|p| p.to_a }
    gpx_file.points.map {|p| puts p.time }
    render 'show'
  end

  def track_params
    params[:track]
  end

end
