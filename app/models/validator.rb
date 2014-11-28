class Validator < ActiveRecord::Base


  # Constructor
  # @param participant_result Result of a sport session
  #
  # def initialize(participant_result)
  #   @participant_result = participant_result
  # end

  def set_participant_result(participant_result)
    @participant_result = participant_result
  end

  # Must be implemented by subclass
  def validate(rules)
    raise 'Implement!'
  end

end