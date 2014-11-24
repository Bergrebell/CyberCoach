class TracksController < ApplicationController

  def index

  end

  def new

  end

  def create
    uploaded_file = track_params[:file]

    gpx_file = GPX::File.new uploaded_file.tempfile
    @points = gpx_file.points
    render 'show'
  end

  def track_params
    params[:track]
  end

end
