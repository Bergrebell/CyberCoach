module GPX

  class TrackReader

    attr_accessor :points, :center_of_gravity, :heights, :statistics, :paces, :speeds

    def initialize(xml)

      # read the xml string as a gpx file
      @gpx_file = GpxRuby::XML(xml)

      @heights = @paces = @speeds = @statistics = @points = []

      # get track data
      @track = @gpx_file.tracks.first # only consider the first track
      if @track
        @center_of_gravity = @track.center_of_gravity.to_a
        @track_points = @track.points
        @points = @track_points.map { |p| p.to_a }

        preprocess_data
        compute_height_profile
        compute_pace_profile
        compute_speed_profile
        compute_average_statistics
      end
    end

    private

    # Processes track data and computes necessary help variables.
    def preprocess_data
      # select all points where a time value is present
      @time_points = @track_points.select { |p| !p.time.nil? }

      # compute total time in seconds
      @total_time = @time_points.last.time - @time_points.first.time rescue 0

      # computes point distances for a sequence of track points
      @point_distances = compute_point_distances(@track_points) # in meters
      @total_distance = compute_total_distance(@point_distances) # in meters
      @accumulated_point_distances = compute_accumulated_distances(@point_distances) # in meters

      # computes time points distances for a sequence of time points
      @time_point_distances = compute_point_distances(@time_points) # in meters
      @total_distance_for_time_points = compute_total_distance(@time_point_distances) # in meters
      @accumulated_time_point_distances = compute_accumulated_distances(@time_point_distances) # in meters
    end


    def compute_height_profile
      # compute height stats
      # zip height values with different accumulated km values
      height_values = @track_points.map { |p| p.elevation } # map to height values
      accumulated_point_distances_in_km = @accumulated_point_distances.map {|distance| distance / 1000.to_f }
      @heights = accumulated_point_distances_in_km.zip(height_values).select { |(_, ele)| !ele.nil? } || []
    end


    def compute_pace_profile
      # compute pace stats
      # compute pace value for different km intervals
      paces = compute_buckets(@accumulated_time_point_distances, @time_points, 1) do |dx_m, dt_seconds|
        if dx_m == 0
          nil
        else
          dt_seconds/(dx_m.to_f) # pace in seconds per meters
        end
      end
      # map to a list of key value pairs
      @paces = paces.map { |k, v| [k, v] }
    end


    def compute_speed_profile
      # compute speed stats
      # compute speed value for different km intervals
      speeds = compute_buckets(@accumulated_time_point_distances, @time_points, 1) do |dx_m, dt_seconds|
        if dt_seconds == 0
          0
        else
          (dx_m)/dt_seconds.to_f # speed in m per seconds
        end
      end
      # map to a list of key value pairs
      @speeds = speeds.map { |k, v| [k, v] }
    end


    def compute_average_statistics
      total_time, total_distance = @total_time, @total_distance_for_time_points

      avg_speed = total_distance/total_time.to_f rescue nil
      avg_pace = total_time/total_distance.to_f rescue nil

      max_pace = @paces.map { |(_, v)| v }.max rescue nil
      min_pace = @paces.map { |(_, v)| v }.min rescue nil

      max_speed = @speeds.map { |(_, v)| v }.max rescue nil
      min_speed = @speeds.map { |(_, v)| v }.min rescue nil

      max_height = @heights.map { |(_, v)| v }.max rescue nil
      min_height = @heights.map { |(_, v)| v }.min rescue nil


      statistics = [
          {key: :total_distance, value: total_distance, unit: :meters},
          {key: :total_time, value: total_time, unit: :seconds},
          {key: :average_speed, value: avg_speed, unit: :meters_per_seconds},
          {key: :average_pace, value: avg_pace, unit: :seconds_per_meters},
          {key: :max_speed, value: max_speed, unit: :meters_per_seconds},
          {key: :min_speed, value: min_speed, unit: :meters_per_seconds},
          {key: :min_pace, value: min_pace, unit: :seconds_per_meters},
          {key: :max_pace, value: max_pace, unit: :seconds_per_meters},
          {key: :min_height, value: min_height, unit: :meters},
          {key: :max_height, value: max_height, unit: :meters},
      ]
      # dirty hack for removing nil and NaN values
      @statistics = statistics.select { |measure|  JSON.parse(measure.to_json)['value'] != nil  }
    end


    # Computes the accumulated distance of a list of distances between points,
    #
    # @param [List] distances
    # @return [List]
    def compute_accumulated_distances(distances)
      acc_distances = []
      distances.reduce do |acc, distance|
        acc += distance
        acc_distances << acc
        acc
      end
      acc_distances
    end


    # Computes the distance of a sequence of points.
    #
    # @param [List] points
    # @return [List] list of distances
    def compute_point_distances(points)
      if points.size >= 2
        paired_points = points[0...-1].zip(points[1..-1])
        distances = [0]
        distances + paired_points.map { |(p, q)| p.distance(q) }
      else
        []
      end
    end


    # Computes the total distance of a list of distances.
    #
    # @param [List] distances
    # @return [Float] total distance
    def compute_total_distance(distances)
      if distances.size != 0
        distances.reduce(:+)
      else
        0
      end
    end


    # Computes buckets for a list of accumulated distances and a list of points.
    #
    # @param [List] accumulated_distances
    # @param [List] points
    # @param [Integer] precision
    # @param [Block] block
    # @return [Hash] buckets
    #
    def compute_buckets(accumulated_distances, points, precision, &block)
      paired_distances_and_points = accumulated_distances.zip(points)
      # hash time points in the same distance buckets with a precision of one fractional digit
      intervals = {}
      paired_distances_and_points.each do |(distance_m, point)|
        distance_km = distance_m / 1000.to_f
        intervals[distance_km.round(precision)] ||= []
        intervals[distance_km.round(precision)] << [distance_m, point.time]
      end

      buckets = {}
      begin
        intervals.each do |key, a_list|
          first_distance_m, first_time = a_list.first
          second_distance_m, second_time = a_list.last
          dx_m = second_distance_m - first_distance_m
          dt_seconds = second_time - first_time
          value = block.call dx_m, dt_seconds
          buckets[key] = value if !value.nil? #ignore nil values
          raise 'Error' if  !value.nil? && !(value < Float::INFINITY)
        end
      rescue => e
        raise e #TODO: remove this line
        buckets = Hash.new
      end
      buckets
    end

  end

end