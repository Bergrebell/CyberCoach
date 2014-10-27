module RestAdapter

  module Models

    # Subscription implements an adapter for the resource Subscription
    # from the Cyber Coach Server.

    # It provides simple interface for retrieving, saving, updating
    # and deleting Subscriptions.
    #
    class Subscription < BaseResource
      include RestAdapter::Models::RetrievableWithParams::Subscription
      # set subscription resource specific config values

      # getters and setters
      attr_accessor :sport, :user, :partnership, :public_visible, :date_subscribed

      set_resource 'subscription'
      set_resource_path users: '/users', partnerships: '/partnerships'

      serialize_properties :public_visible
      deserialize_properties :id, :uri, :partnership, :entries, :user, :public_visible, :date_subscribed, :date_created, :sport

      after_deserialize do |params|
        properties = Hash.new
        properties.update({user: User.create(params['user'])}) if not params['user'].nil?
        properties.update({partnership: Partnership.create(params['partnership'])}) if not params['partnership'].nil?
        properties.update({sport: Sport.create(params['sport'])}) if not params['sport'].nil?
        properties.update({entries: params['entries'].map { |p| Entry.create p }}) if not params['entries'].nil?
      end

      # open eigenclass to override class methods from the base resource class.
      class << self


      end

      # This method overrides 'id' from the base resource class.
      def id
        if not defined? @id or @id.nil?
          part = !user.nil? ? user.username : partnership.id
          "#{part}/#{sport}"
        else
          @id
        end
      end

      # This method overrides 'uri' from the base resource class.
      def uri
        if not defined? @uri or @uri.nil?
          key = !user.nil? ? :users : :partnerships
          self.class.site + self.class.resource_path[key] + '/' + self.id
        else
          @uri
        end
      end


      def create_absolute_uri
        path_key = !user.nil? ? :users : :partnerships
        self.class.base + self.class.site + self.class.resource_path[path_key] + '/' + id
      end


      # This method returns a collection of entries.
      def entries
        entries = self.entries.map { |p| p.fetch }
      end


    end
  end
end