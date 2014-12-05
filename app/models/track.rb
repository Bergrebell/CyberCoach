class Track < ActiveRecord::Base

  belongs_to :user
  belongs_to :sport_session_participant
  belongs_to :sport_session

  #
  # This helper class represents a measure.
  # It helps to convert a measure to a desired unit like meters, kilometers etc.
  # Internally the variable @value uses SI units for the common measures (meters, seconds, meters per seconds).
  #
  class Measure

    attr_accessor :name, :value, :unit, :key

    def initialize(a_hash)
      @key = a_hash[:key]
      @name = a_hash[:key].to_s.gsub('_', ' ').capitalize
      @value = a_hash[:value]
      @unit = a_hash[:unit]
    end


    #
    # Measure factory method. Maps a hash to a measure object by means of the value a_hash[:key].
    # @params [Hash] a_hash - a_hash which represents a measure
    #
    # By means of the key value its mapped to the right measure object.
    # ====Examples
    # a_hash[:key] = :total_distance => mapped to an instance of Distance
    # a_hash[:key] = :total_time => mapped to an instance of MyTime
    #
    def self.create(a_hash)
      key = a_hash[:key]
      case key
        when /speed/
          Speed.new a_hash
        when /distance/
          Distance.new a_hash
        when /pace/
          Pace.new a_hash
        when /time/
          MyTime.new a_hash
        when /height/
          Height.new a_hash
        else
          raise 'Error: %s' % key
      end
    end


    def to_s
      @value.to_s
    end


    def to_i
      @value.to_i
    end


    def to_f
      @value.to_f
    end

  end


  # Specialized measures

  #
  # This class represents a speed measure. Internally speed is saved in meters per seconds.
  #
  class Speed < Measure

    def to_s
      "#{(@value * 3.6).round(2)} km/h" rescue @value.class.name
    end

  end


  #
  # This class represents a pace measure. Internally pace is saved in seconds per meters.
  #
  class Pace < Measure

    def to_s
      minutes_per_km = @value.to_f*(60/3.6) # seconds / meters * 1/3.6 * 60 => minutes / kilometers
      "#{(minutes_per_km).round(2)} minutes per km"
    end

  end


  #
  # This class represents a distance measure. Internally distance is saved in meters.
  #
  class Distance < Measure

    def to_s
      "#{(@value/1000.to_f).round(2)} km"
    end

    def to_meters
      @value.to_f.round(2)
    end

    def to_kilometers
      (@value.to_f/1000).round(2)
    end

    alias_method :m, :to_meters
    alias_method :km, :to_kilometers

  end


  #
  # This class represents a height measure. Internally height is saved in meters.
  #
  class Height < Measure

    def to_s
      "#{@value.round(2)} m"
    end

    def to_meters
      @value.to_f.round(2)
    end

    def to_kilometers
      (@value.to_f/1000).round(2)
    end

    alias_method :m, :to_meters
    alias_method :km, :to_kilometers

  end


  #
  # This class represents a time measure. Internally time is saved in seconds.
  #
  class MyTime < Measure

    def to_s
      Time.at(@value).utc.strftime('%-H hours, %-M minutes, %-S seconds')
    end

    def to_seconds
      @value.to_f.round(2)
    end

    def to_minutes
      (@value.to_f/60).round(2)
    end

    def to_hours
      (@value.to_f/60*60).round(2)
    end

    alias_method :m, :to_minutes
    alias_method :s, :to_seconds
    alias_method :h, :to_hours

  end


  #
  # This helper class represents a data container which is used in the views
  # to avoid passing to much variables to a view.
  #
  class TrackDataContainer

    attr_accessor :speeds, :paces, :heights, :points, :center_of_gravity

    def initialize(a_hash={points: [], speeds: [], paces: [], heights: [], statistics: [], center_of_gravity: [0, 0]})
      @speeds = a_hash[:speeds].map { |(km, v)| [km, v *3.6] } # map to meters per seconds
      @paces = a_hash[:paces].map { |(km, v)| [km, v * 60/3.6] } # map to seconds per meters
      @heights = a_hash[:heights]
      @statistics = a_hash[:statistics].select { |measure| measure[:value] }.map { |measure| Measure.create(measure) }
      @points = a_hash[:points]
      @center_of_gravity = a_hash[:center_of_gravity]
    end


    def statistics(key=nil)
      if key
        @statistics.detect { |measure| measure.key == key }
      else
        @statistics
      end
    end

  end


  def self.create_track_and_update_result(result, uploaded_file)
    # get necessary values to create a track object
    participant_id, user_id, sport_session_id = result.sport_session_participant.id, result.sport_session_participant.user_id, result.sport_session_participant.sport_session_id
    track = Track.where(sport_session_participant_id: participant_id, user_id: user_id, sport_session_id: sport_session_id).first_or_initialize
    track_data_container = track.store_gpx_file(uploaded_file)

    # set result values
    result.time = track_data_container.statistics(:total_time).nil? ? results_params[:time] : track_data_container.statistics(:total_time).to_minutes
    result.length = track_data_container.statistics(:total_distance).nil? ? results_params[:length] : track_data_container.statistics(:total_distance).to_meters
    track
  end


  def store_gpx_file(uploaded_file)
    begin
      gpx_file = uploaded_file.tempfile
      xml = File.open(gpx_file) { |file| file.read }
      track_reader = GPX::TrackReader.new(xml)
      a_hash = {
          points: track_reader.points,
          center_of_gravity: track_reader.center_of_gravity,
          heights: track_reader.heights,
          paces: track_reader.paces,
          speeds: track_reader.speeds,
          statistics: track_reader.statistics
      }
      self.format = File.extname uploaded_file.original_filename
      self.raw_data = xml
      self.data = a_hash.to_json
      TrackDataContainer.new(a_hash)
    rescue => e
      raise e
      TrackDataContainer.new
    end
  end


  def read_track_data
    json = self.data
    if json.present?
      a_hash = JSON.parse(json, symbolize_names: true)
      TrackDataContainer.new(a_hash)
    else
      TrackDataContainer.new
    end
  end

end