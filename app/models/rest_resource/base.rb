require 'addressable/uri'

class RestResource::Base < ActiveRecord::Base

  has_no_table

  # make properties directly accessible
  attr_reader :properties

  # Creates a new object of the corresponding class.
  def initialize(properties={})
    # 0) make properties accessible via symbols
    @properties = Hash[properties.map{ |k,v| [k.to_sym, v]}]
    changed(false)

    # 1) create empty instance variables,
    # setters and getters methods for registered properties
    self.class.get_registered_properties.each do |property|
      create_accessor(property)
    end

    # 2) set properties according the properties hash
    properties.each do |property, value|
      property = property.to_sym if not property.is_a?(Symbol)
      setter_name = "#{property}=".to_sym
      begin
        self.send setter_name, value
      rescue # if value is not mapped according the class just create it on the fly.
        create_accessor(property)
        self.send setter_name, value
        self.class.add_property(property)
      end
    end

    changed(false)
  end

  # Returns the id of this object.
  def id
    @properties[self.class.id]
  end


  def save
    begin
      uri = detail_resource_uri
      serializer = self.class.get_serializer
      changed(true) #mark all attributes as changed
      xml = serializer.call(@properties,@changed)
      response = RestClient.put(uri,xml,{
          accept: self.class.format,
          content_type: self.class.format
      })

      deserializer = self.class.get_deserializer
      deserializer.call(response)
    rescue
      false
    end
  end


  def load(params=nil)
    resource_id = params.nil? ? self.id : params[:id]
    uri = self.class.resource_uri << '/' << resource_id
    response = RestClient.get(uri, {
        content_type: self.class.format,
        accept: self.class.format
    })
    # get deserializer
    deserializer = self.class.get_deserializer
    deserializer.call(response)
  end

  alias_method :read, :load


  def update(params)
    begin
      uri = detail_resource_uri
      serializer = self.class.get_serializer
      xml = serializer.call(@properties,@changed)

      response = RestClient.put(uri,xml,{
          accept: self.class.format,
          content_type: self.class.format,
          authorization: self.class.basic_auth_encryption(params)
      })

      deserializer = self.class.get_deserializer
      deserializer.call(response)
    rescue
      false
    end
  end


  def delete(params)
    begin
      uri = detail_resource_uri
      serializer = self.class.get_serializer
      xml = serializer.call(@properties,@changed)

      response = RestClient.delete(uri,{
          accept: self.class.format,
          content_type: self.class.format,
          authorization: self.class.basic_auth_encryption(params)
      })

      deserializer = self.class.get_deserializer
      deserializer.call(response)
    rescue
      false
    end
  end

  # Retrieves a collection of objects.
  def self.all(params={query: { start: 0, size: 999}})
    q = if not params[:query].nil?
      uri = Addressable::URI.new
      uri.query_values = params[:query]
      q = '?' << uri.query
    else
      ''
    end

    # use filter if not nil, otherwise use identity filter
    filter = params[:filter].nil? ? ->(x) { true } : params[:filter]

    response = RestClient.get(self.resource_uri << q, {
        content_type: self.format,
        accept: self.format
    })
    # get deserializer
    deserializer = self.get_deserializer
    results = deserializer.call(response)
    results = results.select { |r| filter.call(r) }
  end


  # Retrieves a collection of objects.
  def self.find(params={})
    self.all(params)
  end


  # Retrieves the first object which satisfies the filter condition.
  def self.find_first(params={})
    raise 'Filter missing' if params[:filter].nil?
    # if query params are missing add default params
    params = params.update({query: { start: 0, size: 999}}) if params[:query].nil?
    results = self.all(params)
    results.empty? ? nil : results.first
  end


  def to_s
    values = @properties.values.map {|x| x.to_s}.select { |x| not x.empty? }
    '{' << values.join(',') << '}'
  end


  class << self

    #Sets the identifier property for this class.
    def set_id(identifier=nil)
      @@id = identifier if not identifier.nil?
      @@id
    end

    alias_method :id, :set_id


    # Take fields as list and set the class variable fields.
    def set_properties(*properties)
      @@properties = properties
    end

    alias_method :properties, :set_properties


    # Returns all registered properties that are mapped.
    def get_registered_properties
      @@properties
    end

    def add_property(property)
      @@properties << property
    end

    def set_base(url=nil)
      #hack alert: method is setter and getter at the same time
      @@base = url if not url.nil? #set value if available
      @@base = url[0...-1] if not url.nil? and url[-1] == '/' #remove backslash if available
      @@base #return value
    end

    alias_method :base_uri, :set_base


    def set_resource(resource=nil)
      #hack alert: method is setter and getter at the same time
      @@resource = resource if not resource.nil? #set value if available
      #remove backslash if available
      @@resource = resource[0...-1] if not resource.nil? and resource[-1] == '/'
      @@resource #return value
    end

    alias_method :resource_path, :set_resource


    def set_format(format=nil)
      #hack alert: method is setter and getter at the same time
      @@format = format if not format.nil? # set value if available
      @@format
    end

    alias_method :format, :set_format


    # Returns the full uri of this resource (collection_uri).
    def resource_uri
      @@base + @@resource
    end

     # Takes a block as argument and sets it as deserializer for this class.
    # The deserializer is used to deserialize incoming xml messages to objects.
    def set_deserializer(&block)
      @@deserializer = block
    end

    # Returns the deserializer that is associated with this class.
    def get_deserializer
      # if deserializer is not defined return default deserializer
      if not defined? @@deserializer
        # create a closure as default deserializer
        ->(xml) { Hash.from_xml(xml) }
      else
        @@deserializer
      end
    end

    alias_method :deserializer, :set_deserializer


    # The serializer is used to serialize objects for outgoing xml messages.
    def set_serializer(&block)
      @@serializer = block
    end

    alias_method :serializer, :set_serializer


    # Returns the serializer that is associated with this class.
    def get_serializer
      # if serializer is not defined return default deserializer
      if not defined? @@deserializer
        # create a closure as default serializer
        ->(properties) { properties.to_xml(root: self.name) }
      else
        @@serializer
      end
    end


    def basic_auth_encryption(params)
      'Basic '  << Base64.encode64("#{params[:username]}:#{params[:password]}")
    end

  end

  private

  def changed(boolean)
    # mark all properties as unchanged
    @changed = Hash[@properties.map{ |k,v| [k.to_sym, boolean]}]
  end


  # Returns the full uri of this resource (entity_uri).
  def detail_resource_uri
    self.class.resource_uri + '/' + self.id
  end

  # Creates dynamically getters and setters for an object.
  def create_accessor(field)
    field = field.to_sym if not field.is_a?(Symbol)
    @properties[field] = ''

    setter_name = "#{field}=".to_sym
    getter_name = "#{field}".to_sym

    define_singleton_method getter_name do
      @properties[field]
    end

    define_singleton_method setter_name do |value|
      @properties[field] = value
      @changed[field] = true
    end
  end

end
