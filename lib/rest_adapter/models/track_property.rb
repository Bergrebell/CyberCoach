require 'base64'
require 'json'

module RestAdapter

  module Models

    module ParseHelper

      def from_json(data)
        JSON.parse(data)
      end

      def from_xml(data)
        Hash.from_xml(data)
      end

    end

    class TrackProperty

      attr_accessor :data

      def initialize(hash)
        @data = hash
      end

      def to_s
        Base64.encode64(@data.to_json)
      end

      def self.create(base64)
        data = Base64.decode64(base64)
        mapped_data = [:from_xml, :from_json].map do |method|
          begin
            ParseHelper.send method, data
          rescue
            nil
          end
        end
        mapped_data << data
        self.new mapped_data.detect { |x| x !=nil }
      end

    end

  end

end