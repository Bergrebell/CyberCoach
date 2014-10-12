require 'addressable/uri'
# This class provides a generic mapper for simple resources for the cyber coach service.
#
# It does not fit to all resources, thus some customized subclass are necessary.
# The main goal of this class is to map simple resources, to create setters and getters for all predefined properties
# and to give the user a look-a-like rails model with new, all, find, save, update.
#
#
class RestResource::Base



  # make properties directly accessible
  attr_reader :properties

  #
  def initialize(properties={})
    # 1) make properties accessible via symbols
    initialize_properties(properties)
    # 2) create setters and getters for the registered properties
    create_accessors
  end

  # Initializes the current object of the corresponding with the given properties.
  def initialize_properties(properties={})
    @properties = Hash[properties.map{ |k,v| [k.to_sym, v]}]
  end


  # Creates all setters and getters methods for the properties.
  def create_accessors
    keys = self.class.registered_properties #get keys for all registered properties
    keys.each do |property|
      create_accessor(property)
    end
  end

  # Returns the id of this object.
  def id
    @properties[self.class.id]
  end


  # Creates a new object.
  def save(params={})
    # basic options
    options = {
        accept: self.class.format,
        content_type: self.class.format
    }

    if params[:username] and params[:password]
      options = options.merge({authorization: self.class.basic_auth_encryption(params)})
    end

    begin
      uri = entity_resource_uri
      serializer = self.class.get_serializer
      changed(true) #mark all attributes as changed
      xml = serializer.call(serializable_properties)
      response = RestClient.put(uri,xml,options)

      deserializer = self.class.get_deserializer
      deserializer.call(response)
    rescue
      false
    end
  end


  # Loads all details of this object.
  def load
    uri = entity_resource_uri
    response = RestClient.get(uri, {
        content_type: self.class.format,
        accept: self.class.format
    })
    # get deserializer
    deserializer = self.class.get_deserializer
    deserializer.call(response)
  end

  alias_method :read, :load


  # Updates this object.
  # params = {username: username, password: password }
  def update(params)
    begin
      uri = entity_resource_uri
      serializer = self.class.get_serializer
      xml = serializer.call(serializable_properties)

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


  def serializable_properties
    keys = self.class.serializable_properties
    @properties.select {|property,v| keys.include?(property)}
  end


  # Deletes this object.
  # params = {username: username, password: password }
  def delete(params)
    begin
      uri = entity_resource_uri
      serializer = self.class.get_serializer

      xml = serializer.call(serializable_properties)

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
  # If provided it takes a hash as argument with the following properties:
  # params = { filter: filter function,
  #            query: {
  #                     start: number1,
  #                     size: number2
  #                   }
  # }
  #
  # query (optional): these parameters specifies which objects in the range of start to size should be retrieved.

  def self.all(params={})

    # if query is not set use default
    if params[:query].nil?
      params = params.merge({query: { start: 0, size: 999}})
    end

    # build query
    uri = Addressable::URI.new
    uri.query_values = params[:query]
    q = '?' + uri.query

    response = RestClient.get(self.collection_resource_uri + q, {
        content_type: self.format,
        accept: self.format
    })
    # get deserializer
    deserializer = self.get_deserializer
    results = deserializer.call(response)
  end


  # Retrieves a collection of objects.
  # It takes a hash as argument with the following properties:
  # params = { filter: filter function,
  #            query: {
  #                     start: number1,
  #                     size: number2
  #                   }
  # }
  #
  # filter (necessary): the filter function filters the retrieved objects according the provided function.
  # query (optional): these parameters specifies which objects in the range of start to size should be retrieved.

  def self.find(params={})
    raise 'Filter missing' if params[:filter].nil?
    results = self.all(params)
    filter = params[:filter]
    results = results.select {|x| filter.call(x)}
  end


  # Retrieves the first object which satisfies the filter function.
  # It takes a hash as argument with the following properties:
  # params = { filter: filter function,
  #            query: {
  #                     start: number1,
  #                     size: number2
  #                   }
  # }
  #
  # filter (necessary): the filter function filters the retrieved objects according the provided function.
  # query (optional): these parameters specifies which objects in the range of start to size should be retrieved.

  def self.find_first(params={})
    raise 'Filter missing' if params[:filter].nil?
    results = self.find(params)
    results.empty? ? nil : results.first
  end


  # Returns a string representation for this object.
  def to_s
    values = @properties.values.map {|x| x.to_s}.select { |x| not x.empty? }
    '{' << values.join(',') << '}'
  end


  class << self

    #Sets the identifier property for this class.
    def set_id(identifier=nil)
      @id = identifier if not identifier.nil?
      @id
    end

    alias_method :id, :set_id


    # Take fields as list and set the class variable fields.
    def set_properties(*properties)
      @properties = properties
      @serializable_properties = properties
    end

    alias_method :properties, :set_properties


    def registered_properties
      @properties
    end


    def set_site(url=nil)
      #hack alert: method is setter and getter at the same time
      @site = url if not url.nil? #set value if available
      @site = url[0...-1] if not url.nil? and url[-1] == '/' #remove backslash if available
      @site #return value
    end

    alias_method :site_uri, :set_site

    def set_base(url=nil)
      #hack alert: method is setter and getter at the same time
      @base = url if not url.nil? #set value if available
      @base = url[0...-1] if not url.nil? and url[-1] == '/' #remove backslash if available
      @base #return value
    end

    alias_method :base_uri, :set_base


    def set_resource(resource=nil)
      #hack alert: method is setter and getter at the same time
      @resource = resource if not resource.nil? #set value if available
      #remove backslash if available
      @resource = resource[0...-1] if not resource.nil? and resource[-1] == '/'
      @resource #return value
    end

    alias_method :resource_path, :set_resource


    def set_format(format=nil)
      #hack alert: method is setter and getter at the same time
      @format = format if not format.nil? # set value if available
      @format
    end

    alias_method :format, :set_format


    # Returns the full uri of this resource (collection_uri).
    def collection_resource_uri
      @base + @site + @resource
    end


    #
    def serializable(*params)
      @serializable_properties = params.include?(:none) ? [] : params
    end

    def serializable_properties
      @serializable_properties
    end

    # Takes a block as argument and sets it as deserializer for this class.
    # The deserializer is used to deserialize incoming xml messages to objects.
    def set_deserializer(&block)
      @deserializer = block
    end

    # Returns the deserializer that is associated with this class.
    def get_deserializer
      # if deserializer is not defined return default deserializer
      if not defined? @deserializer
        # create a closure as default deserializer
        ->(xml) { Hash.from_xml(xml) }
      else
        @deserializer
      end
    end

    alias_method :deserializer, :set_deserializer


    # The serializer is used to serialize objects for outgoing xml messages.
    def set_serializer(&block)
      @serializer = block
    end

    alias_method :serializer, :set_serializer


    # Returns the serializer that is associated with this class.
    def get_serializer
      # if serializer is not defined return default deserializer
      if not defined? @deserializer
        # create a closure as default serializer
        ->(properties) { properties.to_xml(root: self.name) }
      else
        @serializer
      end
    end


    # Builds a basic auth string and returns the final basic auth string.
    # params = {username: username, password: password }
    def basic_auth_encryption(params)
      'Basic '  << Base64.encode64("#{params[:username]}:#{params[:password]}")
    end

  end

  protected

  # Returns the full uri of this resource (entity_uri).
  def entity_resource_uri
    if self.uri.nil?
      self.class.collection_resource_uri + '/' + self.id
    else
      self.class.base_uri + self.uri
    end
  end

  private

  # Marks all properties has changed if boolean=true or as unchanged if boolean=false.
  def changed(boolean)
    # mark all properties as unchanged
    @changed = Hash[@properties.map{ |k,v| [k.to_sym, boolean]}]
  end



  # Creates dynamically getters and setters for this property..
  def create_accessor(property)
    setter_name = "#{property}=".to_sym
    getter_name = "#{property}".to_sym
    define_singleton_method getter_name do
      @properties[property]
    end

    define_singleton_method setter_name do |value|
      @properties[property] = value
    end
  end

end
