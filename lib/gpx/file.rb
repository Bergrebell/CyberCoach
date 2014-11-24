module GPX


  class File

    attr_accessor :points

    def initialize(a_file)
      @doc = Nokogiri::XML(a_file)
      parse
    end

    private

    def parse
      track_points = @doc.xpath('//xmlns:trkpt')
      @points = track_points.map do |track_point|
        lat = track_point.xpath('@lat').to_s.to_f
        lon = track_point.xpath('@lon').to_s.to_f
        [lat,lon]
      end
    end

  end


end