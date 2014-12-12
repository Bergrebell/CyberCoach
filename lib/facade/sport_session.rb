module Facade

  class SportSession
    include Facade::Wrapper

    class Running < SportSession

    end

    class Boxing < SportSession

    end

    class Cycling < SportSession

    end

    class Soccer < SportSession

    end


    # Delegate all calls to the rails SportSession model and encapsulate the result.
    def self.method_missing(meth, *args, &block)
      # catch all calls and encapsulate them in a block
      query do
        ::SportSession.send(meth, *args, &block)
      end
    end


    def self.wrap(rails_object)
      coach_object = Coach.entry_by_uri(rails_object.cybercoach_uri)
      SportSessionProxy.new rails_object, coach_object
    end

  end

  class SportSessionProxy
    include Facade::RailsModel

    attr_reader :rails_object, :coach_object

    def initialize(rails_object, coach_object=OpenStruct.new)
      @rails_object = rails_object
      @coach_object = coach_object
    end


    def method_missing(meth, *args, &block)
      @rails_object.send meth, *args, &block
    end


    def course_type
      @coach_object.coursetype
    end


    def course_length
      @coach_object.course_length
    end


    def number_of_rounds
      @coach_object.number_of_rounds
    end


    def comment
      @coach_object.comment
    end


    def entry_location
      @coach_object.entry_location
    end


    def entry_duration
      @coach_object.entryduration
    end


    def round_duration
      @coach_object.round_duration
    end


  end

end

