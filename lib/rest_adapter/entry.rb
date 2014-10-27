module RestAdapter
  class Entry < BaseResource
    include RestAdapter::Behaviours::DependencyInjector

    set_resource_path ''
    set_resource ''

    attr_accessor :type, :id, :comment, :track, :public_visible, :date_crated, :date_modified,
                  :entry_location, :entry_date, :entry_duration, :subscription,
                  :course_length, :course_type, :bicycle_type, :round_duration, :number_of_rounds

    deserialize_properties :id, :subscription, :comment, :track, :datecreated => :date_created,
                           :datemodified => :date_modified, :entrylocation => :entry_location,
                           :entrydate => :entry_date, :entryduration => :entry_duration,
                           :publicvisible => :public_visible,

                           :roundduration => :round_duration, :numberofrounds => :number_of_rounds,

                           :coursetype => :course_type, :courselength => :course_length,
                           :bicycletype => :bicycle_type



    serialize_properties :comment, :track, :entrylocation => :entry_location,
                         :entryduration => :entry_duration, :publicvisible => :public_visible,

                         :roundduration => :round_duration, :numberofrounds => :number_of_rounds,

                         :coursetype => :course_type, :courselength => :course_length,
                         :bicycletype => :bicycle_type

    inject :subscription => RestAdapter::Subscription

    module Type
      Running = 'entryrunning'
      Cycling = 'entrycycling'
      Boxing = 'entryboxing'
      Soccer = 'entrysoccer'
    end

    class << self

      def deserialize(response)
        hash = JSON.parse(response)
        type = find_out_type(hash)
        raise 'Type error!' if type.nil?
        entry = hash[type]
        entry = entry.merge({ 'type' => type})
        self.new entry
      end

      def find_out_type(hash)
        Type.constants.each do |constant|
          constant_value = Type.const_get(constant)
          return constant_value if not hash[constant_value].nil?
        end
        nil
      end

    end

  end
end