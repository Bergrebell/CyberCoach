require 'pp'
require 'rspec/mocks/standalone'
require 'test_helper'

class TestUserFacade < ActiveSupport::TestCase


  test "if find by works" do
    rails_user = ::User.new name: 'alex'
    rails_user.save(validate: false) # ignore rails validators

    user = Facade::User.find_by(name: 'alex')
    assert user.is_a?(Facade::User)
    assert_not_nil user.real_name

  end

  # facade specific methods

  test "create and delete a new user" do

    hash = {
        username: 'mydummy5',
        password: 'mydummy5',
        email: 'mydummy@mydummy.com',
        real_name: 'my dummy dummy',
        password_confirmation: 'mydummy5',
        public_visible: RestAdapter::Privacy::Public
    }

    user = Facade::User.create hash
    assert user.valid?
    assert user.save
    sleep 3
    another_user = Facade::User.find_by name: 'mydummy5'
    assert another_user.is_a?(Facade::User)
    assert another_user.delete

    assert Facade::User.authenticate(username: 'mydummy5', password: 'mydummy5') == false

  end


  test "update a user" do

    if Facade::User.authenticate(username: 'mydummy11', password: 'mydummy11') == false
      hash = {
          username: 'mydummy11',
          password: 'mydummy11',
          email: 'mydummy@mydummy.com',
          real_name: 'my dummy dummy',
          password_confirmation: 'mydummy11',
          public_visible: RestAdapter::Privacy::Public
      }

      user = Facade::User.create hash
      assert user.valid?
      assert user.save
      sleep 5
    else
      assert Facade::User.authenticate(username: 'mydummy11', password: 'mydummy11')
    end

    another_user = Facade::User.find_by name: 'mydummy11'
    assert another_user.is_a?(Facade::User)
    assert another_user.update(email: 'newemail@test.com',password: 'mydummy11')
    sleep 1.5

    second_user =  Facade::User.find_by name: 'mydummy11'
    assert second_user.email == 'newemail@test.com'
    assert second_user.update(email: 'mydummy@mydummy.com',password: 'mydummy11')

    sleep 1.5

    third_user =  Facade::User.find_by name: 'mydummy11'
    assert third_user.email == 'mydummy@mydummy.com'


  end


  # delegation tests

  test "if username available delegation works" do
    assert Facade::User.username_available?('ThisNameIsNotTaken')
  end


  test "if user authentication works" do
    assert Facade::User.authenticate username: 'asarteam0', password: 'scareface'
  end

  # validation tests

  test "if password confirmation works" do
    hash = {
        username: 'dummy',
        password: 'dummy',
        email: 'dummy@dummy.com',
        real_name: 'dummy dummy',
        password_confirmation: '11111'
    }
    user = Facade::User.create hash
    assert user.valid? == false
    assert user.errors[:password_confirmation]
  end


  test "if password email validation works" do
    hash = {
        username: 'dummy',
        password: 'dummy',
        email: 'nixe email addy',
        real_name: 'dummy dummy',
        password_confirmation: 'dummy'
    }
    user = Facade::User.create hash
    assert user.valid? == false
    assert user.errors[:email]
  end


  test "if real name validation works" do
    hash = {
        username: 'dummy',
        password: 'dummy',
        email: 'dummy@dummy.com',
        password_confirmation: 'dummy'
    }
    user = Facade::User.create hash
    assert user.valid? == false
    assert user.errors[:real_name]
  end


  test "if username validation works" do
    hash = {
        password: 'dummy',
        email: 'dummy@dummy.com',
        real_name: 'dummy dummy',
        password_confirmation: 'dummy'
    }
    user = Facade::User.create hash
    assert user.valid? == false
    assert user.errors[:username]
  end


  test "if username length validation works" do
    hash = {
        username: 'eee',
        password: 'dummy',
        email: 'dummy@dummy.com',
        real_name: 'dummy dummy',
        password_confirmation: 'dummy'
    }
    user = Facade::User.create hash
    assert user.valid? == false
    assert user.errors[:username]
  end


  test "if password length validation works" do
    hash = {
        username: 'dummy',
        password: 'eee',
        email: 'dummy@dummy.com',
        real_name: 'dummy dummy',
        password_confirmation: 'eee'
    }
    user = Facade::User.create hash
    assert user.valid? == false
    assert user.errors[:password]
  end


end