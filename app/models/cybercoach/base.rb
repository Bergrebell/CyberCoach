require 'active_support'

# This class implements a simple model adapter for
# the cyber coach resources. In order to use just extend this class.
#
#
class Cybercoach::Base < ActiveRecord::Base
  has_no_table

  # class variables

  # set site url
  @@site = 'http://diufvm31.unifr.ch:8090'

  # set prefix for cyber coach resources
  @@prefix = '/CyberCoachServer/resources/'

  # set identifier in the subclass to indicate the resource identifier
  # example: @@id = :username  #=> for resource user: users/:username
  @@id = nil


  @@fields = Set.new


  # Creates an object of the corresponding class and initializes
  # the given hash key values as instance variables.
  # For each key value pair setters and getters are create too.
  #
  # ==== Examples
  # class User < Cybcercoach::Base  # => User.new(:username => '...', :)
  # class User < Cybcercoach::Base  # => User.new(username => '...', :)
  #
  def initialize(params={})

    @@fields.each do |field|
      self.set_field(field,'')
      self.create_accessor(field)
    end

    # take the hash and initialize all hash key values as instance variables
    params.each do |field, value|
      # if already symbol convert to string
      field = field.to_s if field.is_a?(Symbol)
      self.set_field(field,value)
      self.create_accessor(field)
    end
  end

  #
  # Mapped object resource operations: save, update, delete, load
  #

  # Retrieves all user details of a user.
  #
  def load
    get_path = self.class.resource_path(resource: self.id)
    response = RestClient.get(get_path, content_type: :xml, accept: :xml)
    resource = self.class.parse_xml(response)
    resource
  end


  # Saves a new resource on the cyber coach server.
  #
  def save(params={})
    hash = self.instance_values # get hash from instance variables
    xml = self.class.hash_to_xml(hash)
    create_path = self.class.resource_path(resource: self.id)

    options = {content_type: :xml, accept: :xml}

    if not params[:username].nil? and not params[:password].nil?
      b64 = self.class.encrypt_basic_auth(params[:username],params[:password])
      options = options.update({authorization: b64})
    end
    RestClient.put(create_path, xml, options)
  end

  # Updates a resource on the remote server.
  #
  def update(params)
    hash = self.instance_values
    xml = self.class.hash_to_xml(hash)
    update_path = self.class.resource_path(resource: self.id)
    b64 = self.class.encrypt_basic_auth(params[:username],params[:password])
    RestClient.put(update_path, xml, content_type: :xml, accept: :xml, authorization: b64)
  end


  def delete(params)
    delete_path = self.class.resource_path(resource: self.id)
    b64 = self.class.encrypt_basic_auth(params[:username],params[:password])
    RestClient.delete(delete_path, content_type: :xml, accept: :xml, authorization: b64)
  end


  # Returns the identifier of this resource.
  #
  def id
    self.instance_variable_get("@#{@@id}".to_sym)
  end


  #
  # class methods
  #

  # Creates a base path for the cyber coach web service.
  #
  def self.base(path, params={})
    query = Array.new
    params.each do |key, value|
      key = key.to_s if key.is_a?(Symbol)
      query_part = '' << key << '=' << value.to_s
      query << query_part
    end
    base_uri = @@site + @@prefix + path
    base_uri = base_uri + '/?' + query.join("&") if not query.empty?
    base_uri
  end


  # Returns a path for a resource where it can be stored.
  #
  def self.resource_path(params={})
    resource = params[:resource]
    resource = '' if resource.nil? # if nil make empty string
    resource = '/' << resource if not resource.nil? #if not nil append resource path
    self.base self.resources + resource
  end

  # Returns a path for collection of resources.
  #
  def self.collection_path
    self.base self.resources
  end

  # Returns the plural name of this resource.
  #
  def self.resources
    self.name.downcase.pluralize
  end

  # Returns the singular name of this resource.
  #
  def self.resource
    self.name.downcase
  end

  # Makes a GET request to a resource of the corresponding class.
  #
  # ==== Examples
  # User.all #=> requests /resources/users
  def self.all
    response = RestClient.get(self.base(self.resources, start: 0, size: 999))
    resources = self.parse_xml(response)
    resources
  end

  # Makes a GET request to a resource of the corresponding class.
  #
  # ==== Examples
  # User.find(:start => -, :size => 10 ) #=> requests /resources/users/?start=0&size=10
  #
  def self.find(params={})
    params[:start] = 0 if params[:start].nil?
    params[:size] = 999 if params[:size].nil?
    # get the filter
    filter = params[:filter]
    params.delete(:filter)

    response = RestClient.get(self.base(self.resources, params))
    resources = self.parse_xml(response)

    if not filter.nil?
      resources = resources.select { |resource| filter.call(resource)}
    end
    resources
  end

  def self.find_first(params)
    resources = self.find(params)
    if not resources.empty?
      result = resources.first
    else
      result = nil
    end
    result
  end


  #
  #
  def set_field(field,value)
    # create symbol
    sym_variable = "@#{field}".to_sym
    # set instance variables
    self.instance_variable_set(sym_variable, value) #create instance variable
  end

  #
  #
  def create_accessor(field)
    # create symbols for getter / setter methods and for instance variable
    sym_variable = "@#{field}".to_sym
    sym_getter = "#{field}".to_sym
    sym_setter = "#{field}=".to_sym

    # create getter
    self.define_singleton_method(sym_getter) do
      self.instance_variable_get(sym_variable)
    end

    # create setter
    self.define_singleton_method(sym_setter) do |value|
      self.instance_variable_set(sym_variable, value)
    end
  end

  private

  def self.encrypt_basic_auth(username,password)
    'Basic ' << Base64.encode64(username << ':' << password)
  end

  # Converts the xml with a list of resources to objects of the corresponding class.
  #
  def self.parse_xml(res)
    hash = Hash.from_xml(res.body)

    if not hash['list'].nil?
      resources = hash['list'][self.resources][self.resource]
      result = resources.map do |params|
        object = self.new(params)
      end
    else
      params = hash[self.resource]
      result = self.new(params)
    end
    result
  end

  # Converts all values in a hash to string values.
  #
  def self.stringify_hash(hash)
    hash.each {|key, value| hash[key] = value.to_s }
    hash
  end

  # Converts a hash to a xml string
  #
  def self.hash_to_xml(hash)
    # convert hash to a xml representation
    hash = self.stringify_hash(hash)
    # get xml representation of the object
    xml = hash.to_xml(root: self.resource).to_s
    xml
  end

end
