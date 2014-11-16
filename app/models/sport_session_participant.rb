class SportSessionParticipant < ActiveRecord::Base
  belongs_to :user
  belongs_to :sport_session

  # Return the correct result object
  #
  def result

    case self.sport_session.type
      when 'Running'
       RunningParticipantResult.where(:sport_session_participant_id => self.id).first_or_initialize
      when 'Boxing'
        BoxingParticipantResult.where(:sport_session_participant_id => self.id).first_or_initialize
      else
        nil
    end

  end


end
