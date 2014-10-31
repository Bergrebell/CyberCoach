module RestAdapter

  module Models


    class TrackProperty

      attr_accessor :data

      def initialize(hash={})
        @data = hash
      end

      def to_s
        Base64.encode64(@data.to_json)
      end

      class << self

        def create(base64)
          data = begin
            Base64.decode64(base64)
          rescue
            base64
          end

          parsed_data = begin
            self.from_json data
          rescue
            Hash.new
          end
          self.new parsed_data
        end

        def from_json(data)
          JSON.parse(data)
        end

      end

    end

  end

end
