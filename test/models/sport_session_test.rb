require 'test_helper'

class SportSessionTest < ActiveSupport::TestCase

  stefan = User.where(:name => 'Stefan').first
  alex = User.where(:name => 'Alex').first
  sveta = User.where(:name => 'Sveta').first
  roman = User.where(:name => 'Roman').first

  # Stefan will create a running sport event
  # Note that the cybercoach_id attribute will hold the ID of the entry on the cybercoach with all details of the sport session
  # The proxy will delegate the data to your rails model so we can for example get/set data with
  # running.course_type = 'Difficult'
  # These data are different for each sport type
  running = Running.new(
      :user_id => stefan.id, :cybercoach_id => 999
  )
  running.save()

  # Invite all of you guys to join, this is for now done with a simple helper method on the SportSession object
  running.invite([alex.id, sveta.id, roman.id])

  # Roman creates a boxing event and invites alex ;)
  boxing = Boxing.new(
      :user_id => roman.id, :cybercoach_id => 1000
  )
  boxing.save()
  boxing.invite([alex.id])

  # Alex does confirm the invitation, if not confirmed, the user has not participated at the event
  p = alex.sport_session_participants.find_by(:sport_session_id => boxing.id)
  p.confirmed = true
  p.save()

  # Get all sport sessions created by Stefan
  events = stefan.sport_sessions

  # Get all Boxing events of Alex
  boxing_events = alex.sport_sessions.where(:type => 'Boxing')

  # Get all sport sessions Sveta has participated
  events = sveta.sport_session_participants.where(:confirmed => true)

  # Get all invitations for sport events of Roman
  invitations = roman.sport_session_participants.where(:confirmed => false)

end
