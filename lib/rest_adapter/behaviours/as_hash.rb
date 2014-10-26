module RestAdapter
  module Behaviours
    module AsHash

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        # Returns a hash representation of this object.
        # As argument it takes an optional hash with two properties :included_keys and :excluded_keys
        # The hash is filtered according the two lists that are provided by :included_keys and :excluded_keys.
        #
        # Examples====
        # user.as_hash(included_keys: [:username,:email]) => { username: 'blah', email: 'blah'}
        # user.as_hash(excluded_keys: [:username,:email]) => hash does not have the properties username and email
        #
        def as_hash(params={})
          # hack alert
          json_string = self.to_json
          hash = JSON.parse(json_string)
          if not params[:included_keys].nil?
            included_keys = Hash[params[:included_keys].map { |k, v| [k.to_s, v] }]
            hash = hash.select { |key, _| included_keys.include? key }
          end

          if not params[:excluded_keys].nil?
            excluded_keys = Hash[params[:excluded_keys].map { |k, v| [k.to_s, v] }]
            hash = hash.select { |key, _| not excluded_keys.include? key }
          end
          hash
        end
      end
    end
  end
end