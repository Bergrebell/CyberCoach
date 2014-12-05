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
      a_hash.delete(:validator) # remove validator attribute
      Achievement.new(a_hash.merge(validator_id: validator.id)).save
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