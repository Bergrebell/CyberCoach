class Running < SportSession

  def get_all_results

    participant_ids = self.sport_session_participants.where(:confirmed => true).map { |participant| participant.id}
    results = RunningParticipantResult.where(:sport_session_participant_id => participant_ids).order('length DESC, time ASC')

  end

end