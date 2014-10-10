require 'test_helper'

class TestPartnership < RestResource::Base


  id :id

  properties :id, :uri

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
      params = hash
      partnership = TestPartnership.new params
    end
  end

  # setup serializer
  serializer do |properties,changed|
    keys = changed.select {|k,v| v==true}.keys
    changed_properties = properties.select {|k,v| keys.include?(k)}
    changed_properties.to_xml(root: 'user')
  end

  def self.load(params)
    puts params
    kx, ky = params.keys[0..1]
    id = params[kx] + ';' + params[ky]
    super(id: id)
  end

end


class PartnershipTest < ActiveSupport::TestCase

  test "get partnerships" do
    partnerships = TestPartnership.all query: { start: 0, size: 5 }

    puts partnerships
  end

  test "get partnership" do
    partnership = TestPartnership.load with: 'lexruee5', and: 'lexruee11'

    puts partnership
  end
end