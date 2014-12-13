module DefinedAchievements
  extend AchievementsCollector

  # Running achievements

  ## Normal achievements

  achievement do
    title 'Flash Runner'
    description 'Average speed between 9km/h and 10 km/h '
    points 100
    validator 'AttributeValidator'
    sport 'Running'
    icon 'one_star'
    rules [{operator: '<=', attribute: 'average_speed', value: 10},
           {operator: '>', attribute: 'average_speed', value: 9}]
  end

  achievement do
    title 'Social Runner' # sveta :-)
    description 'Run with another friend'
    points 100
    validator 'AttributeValidator'
    sport 'Running'
    icon 'running/social_runner'
    rules [{operator: '>=', attribute: 'n_participants', value: 2}]
  end

  achievement do
    title 'Massive Social Runner' # sveta :-)
    description 'Run with at least 20 other friends'
    points 600
    validator 'AttributeValidator'
    sport 'Running'
    icon 'running/social_runner'
    rules [{operator: '>=', attribute: 'n_participants', value: 20}]
  end

  achievement do
    title 'Steinbock' # sveta :-)
    description '2000 meters over the sea!'
    points 100
    validator 'AttributeValidator'
    sport 'Running'
    icon 'capricorn6'
    rules [{operator: '>=', attribute: 'max_height', value: 2000}]
  end

  achievement do
    title 'Basic Runner'
    description 'Run more than 1 kilometer'
    points 100
    validator 'AttributeValidator'
    sport 'Running'
    icon 'running/basic_runner'
    rules [{operator: '>', attribute: 'length', value: 1000}]
  end

  achievement do
    title 'Aspiring Runner'
    description 'Run more than 5 kilometers'
    points 500
    validator 'AttributeValidator'
    sport 'Running'
    icon 'running/aspiring_runner'
    rules [{operator: '>', attribute: 'length', value: 5000}]
  end

  achievement do
    title 'Intermediate Runner'
    description 'Run more than 10 kilometers'
    points 1000
    validator 'AttributeValidator'
    sport 'Running'
    icon 'running/intermediate_runner'
    rules [{operator: '>', attribute: 'length', value: 10000}]
  end

  achievement do
    title 'Advanced Runner'
    description 'Run more than 15 kilometers'
    points 1500
    validator 'AttributeValidator'
    sport 'Running'
    icon 'running/advanced_runner'
    rules [{operator: '>', attribute: 'length', value: 15000}]
  end

  achievement do
    title 'Half Marathon Runner'
    description 'Run more than 20 kilometers'
    points 2000
    validator 'AttributeValidator'
    sport 'Running'
    icon 'running/half_marathon_runner'
    rules [{operator: '>', attribute: 'length', value: 20000}]
  end

  achievement do
    title 'Ambitious Runner'
    description 'Run more than 30 kilometers'
    points 3000
    validator 'AttributeValidator'
    sport 'Running'
    icon 'running/ambitious_runner'
    rules [{operator: '>', attribute: 'length', value: 30000}]
  end

  achievement do
    title 'Marathon Runner'
    description 'Run more than 40 kilometers'
    points 4000
    validator 'AttributeValidator'
    sport 'Running'
    icon 'running/marathon_runner'
    rules [{operator: '>', attribute: 'length', value: 40000}]
  end

  achievement do
    title 'Swiss Soldier Runner'
    description 'Run more than 100 kilometers'
    points 10000
    validator 'AttributeValidator'
    sport 'Running'
    icon 'running/swiss_soldier_runner'
    rules [{operator: '>', attribute: 'length', value: 100000}]
  end


## Special achievements

  achievement do
    title 'A plant!'
    description 'You must be a stone or a plant!'
    points 42 # the answer to everything!
    validator 'AttributeValidator'
    sport 'Running'
    icon 'running/plant'
    rules [
              {operator: '<=', attribute: 'length', value: 1},
              {operator: '>', attribute: 'length', value: 0},
              {operator: '>=', attribute: 'time', value: 60}
          ]
  end

  achievement do
    title 'Prison inmate'
    description 'You must be a prison inmate! '
    points 42 # the answer to everything!
    validator 'AttributeValidator'
    sport 'Running'
    icon 'running/inmate'
    rules [
              {operator: '<=', attribute: 'length', value: 25},
              {operator: '>', attribute: 'length', value: 10},
              {operator: '>=', attribute: 'time', value: 60}
          ]
  end

  achievement do
    title 'Snail Walker'
    description 'Slower than a normal person and a cute Zombie. You must be a Snail Walker?!'
    points 42 # the answer to everything!
    validator 'AttributeValidator'
    sport 'Running'
    icon 'running/snail_walker'
    rules [
              {operator: '<=', attribute: 'length', value: 1000},
              {operator: '>', attribute: 'length', value: 100},
              {operator: '>=', attribute: 'time', value: 60}
          ]
  end

  achievement do
    title 'Cute Zombie Walker'
    description 'Being a Zombie!'
    points 1000
    validator 'AttributeValidator'
    sport 'Running'
    icon 'running/cute_zombie_walker'
    rules [
              {operator: '<=', attribute: 'length', value: 2000},
              {operator: '>', attribute: 'length', value: 1000},
              {operator: '>=', attribute: 'time', value: 60}
          ]
  end

  achievement do
    title 'Dangerous Zombie Walker'
    description 'Being a dangerous Zombie!'
    points 200
    validator 'AttributeValidator'
    sport 'Running'
    icon 'running/dangerous_zombie_walker'
    rules [
              {operator: '<=', attribute: 'length', value: 3000},
              {operator: '>', attribute: 'length', value: 2000},
              {operator: '>=', attribute: 'time', value: 60}
          ]
  end

  achievement do
    title 'Really Dangerous Zombie Walker'
    description 'Being a really dangerous Zombie!'
    points 300
    validator 'AttributeValidator'
    sport 'Running'
    icon 'running/really_dangerous_zombie_walker'
    rules [
              {operator: '<=', attribute: 'length', value: 4000},
              {operator: '>', attribute: 'length', value: 3000},
              {operator: '>=', attribute: 'time', value: 60}
          ]
  end

  # Boxing

  achievement do
    title 'First knockout' # sveta :-)
    description 'Knockout your opponent!'
    points 100
    validator 'AttributeValidator'
    sport 'Boxing'
    icon 'boxing/gloves5'
    rules [{operator: '=', attribute: 'knockout_opponent', value: 1}]
  end

  achievement do
    title 'Karate Kid'
    description 'Knockout your opponent in the first round!'
    points 1000
    validator 'AttributeValidator'
    sport 'Boxing'
    icon 'boxing/karate'
    rules [
              {operator: '=', attribute: 'knockout_opponent', value: 1},
              {operator: '=', attribute: 'number_of_rounds', value: 1}
          ]
  end

  achievement do
    title 'Fast Fists'
    description 'Knockout your opponent in the first two rounds!'
    points 500
    validator 'AttributeValidator'
    sport 'Boxing'
    icon 'boxing/man49'
    rules [
              {operator: '=', attribute: 'knockout_opponent', value: 1},
              {operator: '<=', attribute: 'number_of_rounds', value: 2}
          ]
  end

  achievement do
    title 'Sleeping Beauty'
    description 'Get knocked out in the first round!'
    points 10
    validator 'AttributeValidator'
    sport 'Boxing'
    icon 'boxing/abs1'
    rules [
              {operator: '=', attribute: 'knockout_opponent', value: 0}, #guess that's okay since the fight lasts for only one round ;)
              {operator: '=', attribute: 'number_of_rounds', value: 1}
          ]
  end

  achievement do
    title 'Still standing'
    description 'Fight for full twelve rounds'
    points 250
    validator 'AttributeValidator'
    sport 'Boxing'
    icon 'boxing/tree101'
    rules [
              {operator: '=', attribute: 'knockout_opponent', value: 0},
              {operator: '>=', attribute: 'number_of_rounds', value: 12}
          ]
  end

  achievement do
    title 'Great shape'
    description 'Fight for at least 15 minutes'
    points 350
    validator 'AttributeValidator'
    sport 'Boxing'
    icon 'boxing/sportive'
    rules [
              {operator: '>=', attribute: 'time', value: 15}
          ]
  end

  achievement do
    title 'Punching Bag'
    description 'Get less than 100 points in a fight that takes longer than five rounds'
    points 50
    validator 'AttributeValidator'
    sport 'Boxing'
    icon 'boxing/silhouette41'
    rules [
              {operator: '>=', attribute: 'number_of_rounds', value: 5},
              {operator: '<=', attribute: 'points', value: 100}
          ]
  end


end
