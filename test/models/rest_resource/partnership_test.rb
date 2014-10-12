require 'test_helper'
require 'pp'

class TestPartnership < RestResource::Base


  id :id

  properties :id, :uri, :publicvisible, :userconfirmed1, :userconfirmed2, :user1, :user2
  serializable :none

  base_uri 'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources'

  resource_path '/partnerships/'

  format :xml

  # setup deserializer
  deserializer do |xml|
    hash = Hash.from_xml(xml)
    if hash['list']
      partnerships = hash['list']['partnerships']['partnership']
      partnership = partnerships.map {|params| TestPartnership.new params}
    else
      params = hash['partnership']
      puts params
      partnership = TestPartnership.new params
    end
  end

  # setup serializer
  serializer do |properties,changed|
    keys = changed.select {|k,v| v==true}.keys
    changed_properties = properties.select {|k,v| keys.include?(k)}
    changed_properties.to_xml(root: 'user')
  end


  def initialize(properties)
    initialize_properties(properties)
    create_accessors

  end


  # Return first user of this partnership.
  def first_user
    CyberCoachUser.new self.user1
  end

  # Return second user of this partnership.
  def second_user
    CyberCoachUser.new self.user2
  end

  def confirmed_by_first_user?
    self.userconfirmed1
  end

  def confirmed_by_second_user?
    self.userconfirmed2
  end

  def confirmed_by?(user)
    username = user.kind_of?(CyberCoachUser) ? user.username : user #support username and cyber coach user
    self.user1['username'] == username or self.user2['username'] == username
  end


  def self.find(params)
    first, second = params.kind_of?(Hash) ? params.values : (list = *params) # support hashes and lists
    id = first + ';' + second
    puts self.collection_resource_uri + '/' + id
    response =  RestClient.get(self.collection_resource_uri + '/' + id,{
        accept: self.format,
        content_type: self.format
    })
    puts response
    deserializer = self.get_deserializer
    deserializer.call(response)
  end

end


class PartnershipTest < ActiveSupport::TestCase

  test "get partnerships" do
    partnerships = TestPartnership.all query: { start: 0, size: 5 }
  end

  test "find partnership" do
    partnership = TestPartnership.find with: 'lexruee5', and: 'lexruee11'
    puts partnership.id
    assert_equal 'lexruee5', partnership.first_user.username
    assert_equal 'lexruee11', partnership.second_user.username

  end

  test "partnership confirmation" do
    partnership = TestPartnership.find with: 'lexruee5', and: 'lexruee11'
    user = CyberCoachUser.find_first(filter: ->(user) {user.username == 'lexruee5'})

    # both works, just pass a user object or a username string
    assert partnership.confirmed_by?(user)
    assert partnership.confirmed_by?('lexruee11')

    assert partnership.confirmed_by_first_user?
    assert partnership.confirmed_by_second_user?
  end


  test "propose partnership" do
    shiva = CyberCoachUser.find_first(filter: ->(user) { user.username = 'MikeShiva'})
    lexruee = CyberCoachUser.find_first(filter: ->(user) { user.username = 'lexruee6'})



  end

end