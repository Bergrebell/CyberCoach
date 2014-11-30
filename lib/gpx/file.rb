module GPX

  class File

    attr_accessor :points, :raw_points, :gravity_point, :heights, :raw_heights, :stats, :paces, :speeds

    def initialize(input)
      @doc = Nokogiri::XML(input)
      parse
      compute
    end

    private

    def parse
      track_points = @doc.xpath('//xmlns:trkpt')
      @points = []
      @raw_points = []
      @raw_heights = []
      @times = []
      track_points.each do |track_point|
        time = track_point.css('time').text
        ele = track_point.css('ele').text
        lat = track_point.xpath('@lat').to_s.to_f
        lon = track_point.xpath('@lon').to_s.to_f
        @raw_points << [lat, lon]
        @raw_heights << ele.to_i
        @points << Point.new(lat: lat, lng: lon, time: time, height: ele)
        @times << Time.xmlschema(time)
      end

      slat, slon = @raw_points.reduce { |(lat_acc, lon_acc), (lat, lon)| [lat_acc + lat, lon_acc + lon] }
      @gravity_point = [slat/@raw_points.size.to_f, slon/@raw_points.size.to_f]
    end

    RADIUS_KM = 6371


    def compute
      zipped_points = @raw_points.dup[0...-1].zip(@raw_points.dup[1..-1])
      distances = [0] + zipped_points.map { |(p, q)| distance(p, q) }
      acc_distances =[]

      distances.reduce do |acc, d|
        acc += d
        acc_distances << acc
        acc
      end

      p = 0
      pace = Hash.new
      speed = Hash.new
      zipped = acc_distances.zip(@times)
      zipped.each_with_index do |(km,time),index|
        pace[km.round(1)] = Array.new if pace[km.round(1)].nil?
        pace[km.round(1)] << [km, @times[index]]
      end

      zipped.each_with_index do |(km,time),index|
        speed[km.round(1)] = Array.new if speed[km.round(1)].nil?
        speed[km.round(1)] << [km, @times[index]]
      end


      speed.each do |key,value|
        km1, time1 = speed[key].first
        km2, time2 = speed[key].last
        xd = km2 - km1
        td = time2 - time1
        speed[key] = (xd/(td.to_f/3600.0)).round(2)
      end


      pace.each do |key,value|
        km1, time1 = pace[key].first
        km2, time2 = pace[key].last
        xd = km2 - km1
        td = time2 - time1
        pace[key] = (td/60.0)/(xd.to_f)
      end

      mpace = pace.values.reduce(:+)/pace.length

      @heights = acc_distances.zip(@raw_heights)
      time_delta = @times.last - @times.first
      total_distance = acc_distances.last
      @stats = {
          :distance => "#{total_distance.round(2)} km",
          :time => (Time.at(time_delta).utc.strftime('%H:%M:%S')),
          :speed => "#{(total_distance/(time_delta.to_f/3600.0)).round(2)} km/h", #km/h
          :pace => "#{Time.at(time_delta/(total_distance.to_f)).utc.strftime('%H:%M:%S')} time/km"
      }

      @speeds = speed.map {|k,v| [k+1,v]}
      @paces = pace.map {|k,v| [k+1,v]}.select {|(k,v)| v < 3*mpace }

    end


    def distance(p_point, q_point)
      rad_per_deg, radius_meter = Math::PI/180, RADIUS_KM * 1000

      dlon_rad = (q_point[1]-p_point[1]) * rad_per_deg
      dlat_rad = (q_point[0]-p_point[0]) * rad_per_deg

      lat1_rad, lon1_rad = p_point.map { |i| i * rad_per_deg }
      lat2_rad, lon2_rad = q_point.map { |i| i * rad_per_deg }

      p_point = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
      c = 2 * Math::atan2(Math::sqrt(p_point), Math::sqrt(1-p_point))

      radius_meter * c / 1000.0
    end

  end

end