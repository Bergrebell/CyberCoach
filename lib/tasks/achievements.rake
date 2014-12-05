require 'pp'

namespace :achievements do

  desc "Creates all defined achievement"
  task :create => :environment do
    defined_achievements = DefinedAchievements.list

    # get all validators and group them
    validators = Validator.all.group_by {|v| v.type }
    validators = Hash[validators.map {|k,v| [k, v.first] }] # use the first one

    # create all defined achievements
    defined_achievements.each do |defined_achievement|
      a_hash = defined_achievement.to_hash

      validator = validators[a_hash[:validator]]

      achievement = Achievement.new

      a_hash.each do |key,_|
        # delete keys that are not present in the achievement model object
        a_hash.delete(key) if !achievement.attributes.include?(key.to_s)
      end

      achievement.assign_attributes(a_hash.merge(validator_id: validator.id))
      achievement.save unless Achievement.find_by(title: achievement.title)
    end
  end

  desc "Shows all defined achievements"
  task :definitions => :environment do
    pp DefinedAchievements.list.map {|achievement| achievement.title }
  end

  desc "Shows all saved achievements"
  task :show => :environment do
    pp Achievement.all.map {|a| a.title }
  end

  desc "Deletes all achievements"
  task :delete => :environment do
    Achievement.all.map { |achievement| achievement.delete}
  end

end

namespace :user_achievements do

  desc "Deletes all user achievements"
  task :delete => :environment do
    pp UserAchievement.all.map {|a| a.delete }
  end

end