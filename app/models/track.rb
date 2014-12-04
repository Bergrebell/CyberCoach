class Track < ActiveRecord::Base

  belongs_to :user
  belongs_to :sport_session_participant
  belongs_to :sport_session

  class Measure

    attr_accessor :name, :value, :unit, :key

    def initialize(a_hash)
      @key = a_hash[:key]
      @name = a_hash[:key].to_s.gsub('_', ' ').capitalize
      @value = a_hash[:value]
      @unit = a_hash[:unit]
    end


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


  class Speed < Measure

    def to_s
      "#{(@value * 3.6).round(2)} km/h" rescue @value.class.name
    end

  end


  class Pace < Measure

    def to_s
      minutes_per_km = @value.to_f*(60/3.6) # seconds / meters * 1/3.6 * 60 => minutes / kilometers
      "#{(minutes_per_km).round(2)} minutes per km"
    end

  end


  class Distance < Measure

    def to_s
      "#{(@value/1000.to_f).round(2)} km"
    end

  end


  class Height < Measure

    def to_s
      "#{@value.round(2)} m"
    end

  end


  class MyTime < Measure

    def to_s
      Time.at(@value).utc.strftime('%-H hours, %-M minutes, %-S seconds')
    end

  end


  class TrackDataContainer

    attr_accessor :speeds, :paces, :heights, :points, :center_of_gravity

    def initialize(a_hash={points: [], speeds: [], paces: [], heights: [], statistics: [], center_of_gravity: [0, 0]})
      @speeds = a_hash[:speeds].map { |(km, v)| [km, v *3.6] }
      @paces = a_hash[:paces].map { |(km, v)| [km, v * 60/3.6] }
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