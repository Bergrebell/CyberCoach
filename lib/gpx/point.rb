module GPX

  class Point

    attr_accessor :lat, :lng,:time, :height

    def initialize(params)
      @lat = params[:lat]
      @lng = params[:lng]
      @time = params[:time]
      @height = params[:height]
    end

    def to_a
      [@lat,@lng]
    end


  end

end