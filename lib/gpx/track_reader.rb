module GPX

  class TrackReader

    attr_accessor :points, :points, :center_of_gravity, :heights, :stats, :paces, :speeds

    def initialize(xml)
      @gpx_file = GpxRuby::XML xml
      @track = @gpx_file.tracks.first # only consider the first track
      @center_of_gravity = @track.center_of_gravity.to_a
      compute
    end

    private


    def compute
      points = @track.points
      valid_points = points.select {|p| p.time.nil? == false }

      # compute acc distances
      zipped_points = points[0...-1].zip(points.dup[1..-1])

      valid_zipped_points = valid_points[0...-1].zip(valid_points.dup[1..-1])

      # get distances in meters
      distances = [0]
      valid_distances = [0]
      zipped_points.each  do |(p, q)|
        distances << p.distance(q) / 1000.to_f
        (valid_distances << p.distance(q) / 1000.to_f) if p.time.nil? == false
      end

      acc_distances = []
      valid_acc_distances = []

      distances.reduce do |acc, d|
        acc += d
        acc_distances << acc
        acc
      end

      valid_distances.reduce do |acc,d|
        acc += d
        valid_acc_distances << acc
        acc
      end

      # compute pace and speed for different intervals
      pace, speed = Hash.new, Hash.new
      zipped = acc_distances.zip(points)
      valid_zipped = valid_acc_distances.zip(valid_points)

     # preprocessing
      valid_zipped.each do |(km, point)|
          pace[km.round(1)] = Array.new if pace[km.round(1)].nil?
          pace[km.round(1)] << [km, point.time]
      end

      valid_zipped.each do |(km, point)|
          speed[km.round(1)] = Array.new if speed[km.round(1)].nil?
          speed[km.round(1)] << [km, point.time]
      end

      # compute speed
      begin
        speed.each do |key, a_list|
          km1, time1 = a_list.first
          km2, time2 = a_list.last
          xd = km2 - km1
          td = time2 - time1
          speed[key] = (xd/(td.to_f/3600.0)).round(2)
          raise 'Error' unless speed[key] < Float::INFINITY
        end
      rescue
        speed = Hash.new
      end

      # compute pace
      begin
        pace.each do |key, a_list|
          km1, time1 = a_list.first
          km2, time2 = a_list.last
          xd = km2 - km1
          td = time2 - time1
          pace[key] = (td/60.0)/(xd.to_f)
          raise 'Error' unless pace[key] < Float::INFINITY
        end
        mean_pace = pace.values.reduce(:+)/pace.length
      rescue
        pace = Hash.new
      end

      total_distance = acc_distances.last
      valid_total_distance = valid_acc_distances.last

      begin
        total_time = valid_points.last.time - valid_points.first.time
        avg_speed = "#{(valid_total_distance/(time_delta.to_f/3600.0)).round(2)} km/h"
        avg_pace = "#{Time.at(time_delta/(valid_total_distance.to_f)).utc.strftime('%H:%M:%S')} time/km"
      rescue
        avg_speed = '-'
        avg_pace = '-'
        total_time = '-'
      end

      @stats = {
          :distance => (total_distance * 1000).round(2),
          :time => total_time,
          :speed => avg_speed, #km/h
          :pace => avg_pace
      }

      @heights = acc_distances.zip(points.map {|p| p.elevation }).select {|(_,ele)| ele.nil? == false } || []
      @speeds = speed.map {|k,v| [k+1,v]}
      @paces = pace.map {|k,v| [k+1,v]}.select {|(k,v)| v < 3*mean_pace }
      @points = points.map { |p| p.to_a }

    end

  end

end