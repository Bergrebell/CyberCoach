# Does the job of checking if a user obtains an achievement based on results
#
class AchievementsChecker

  # Constructor
  # @param participant_result A concrete result, e.g. RunningParticipantResult or BoxingParticipantResult
  #
  def initialize(participant_result)
    @participant_result = participant_result
    init
  end

  # Check against all achievements not yet obtained by the user
  # Returns an array of UserAchievement object that the user should obtain based on the validator
  # @param create_achievements If true, also stores the obtained achievements to database
  #
  def check(create_achievements = false)

    user_achievements = []

    @achievements.each do |achievement|

      validator = achievement.validator
      validator.set_participant_result(@participant_result)

      if validator.validate(achievement.rules)
        user_achievement = UserAchievement.new(
            :user_id => @participant.user_id,
            :achievement_id => achievement.id,
            :sport_session_id => @sport_session.id
        )
        user_achievements.push(user_achievement)
      end

    end

    # Save achievements?
    if create_achievements
      user_achievements.each do |achievement|
        achievement.save
      end
    end

    user_achievements

  end

  private

  # Init
  #
  def init
    @participant = @participant_result.sport_session_participant
    @sport_session = @participant_result.sport_session
    @user_achievements = UserAchievement.where(:user_id => @participant.user_id)
    user_achievement_ids = @user_achievements.map { |a| a.achievement_id }
    @achievements = Achievement.where(:sport => @sport_session.type).where.not(:id => user_achievement_ids)
  end

end
