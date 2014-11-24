# Does the job of checking if a user obtains an achievement based on results
#
class AchievementsChecker

  # Constructor
  # @param participant_result A concrete result, e.g. RunningParticipantResult or BoxingParticipantResult
  #
  def initialize(participant_result)
    @participant_result = participant_result
    @participant = @participant_result.sport_session_participant
    @session = @participant.sport_session
    @user_achievements = UserAchievement.where(:user_id => @participant.user_id)
    user_achievement_ids = @user_achievements.map { |a| a.achievement_id }
    @achievements = Achievement.where(:sport => @session.type).where.not(:id => user_achievement_ids)
  end

  # Check against all achievements not yet obtained by the user
  # Returns an array of UserAchievement object that the user should obtain based on the validator
  # @param create_achievements If true, also stores the obtained achievements to database
  #
  def check(create_achievements=false)

    user_achievements = []

    @achievements.each do |achievement|

      validator = achievement.validator

      # Ugly switch but rather having each Validator be implemented without a dependency on result or session...
      case validator.type
        when 'AttributeValidator'

          # This gets all attributes of result object as hash
          attributes = @participant_result.attributes
          if validator.validate(achievement.rules, attributes)
            user_achievement = UserAchievement.new(
                :user_id => @participant.user_id,
                :achievement_id => achievement.id,
                :sport_session_id => @session.id
            )
            user_achievements.push(user_achievement)
          end

        else
          raise "Validator #{validator.type} not yet implemented in Achievements layer"
      end

    end

    #
    if create_achievements
      user_achievements.each do |achievement|
        achievement.save
      end
    end

    user_achievements

  end

end
