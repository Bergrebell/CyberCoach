module DefinedAchievements
  extend AchievementsCollector

  # Running achievements

  ## Normal achievements

  achievement do
    title 'Basic Runner'
    description 'Ran more than 1 kilometer'
    points 100
    validator 'AttributeValidator'
    sport 'Running'
    rules [{operator: '>', attribute: 'length', value: 1000}]
  end

  achievement do
    title 'Aspiring Runner'
    description 'Ran more than 5 kilometers'
    points 500
    validator 'AttributeValidator'
    sport 'Running'
    rules [{operator: '>', attribute: 'length', value: 5000}]
  end

  achievement do
    title 'Intermediate Runner'
    description 'Ran more than 10 kilometers'
    points 1000
    validator 'AttributeValidator'
    sport 'Running'
    rules [{operator: '>', attribute: 'length', value: 10000}]
  end

  achievement do
    title 'Advanced Runner'
    description 'Ran more than 15 kilometers'
    points 1500
    validator 'AttributeValidator'
    sport 'Running'
    rules [{operator: '>', attribute: 'length', value: 15000}]
  end

  achievement do
    title 'Half Marathon Runner'
    description 'Ran more than 20 kilometers'
    points 2000
    validator 'AttributeValidator'
    sport 'Running'
    rules [{operator: '>', attribute: 'length', value: 20000}]
  end

  achievement do
    title 'Ambitious Runner'
    description 'Ran more than 30 kilometers'
    points 3000
    validator 'AttributeValidator'
    sport 'Running'
    rules [{operator: '>', attribute: 'length', value: 30000}]
  end

  achievement do
    title 'Marathon Runner'
    description 'Ran more than 40 kilometers'
    points 4000
    validator 'AttributeValidator'
    sport 'Running'
    rules [{operator: '>', attribute: 'length', value: 40000}]
  end

  achievement do
    title 'Swiss Soldier Runner'
    description 'Ran more than 100 kilometers'
    points 10000
    validator 'AttributeValidator'
    sport 'Running'
    rules [{operator: '>', attribute: 'length', value: 100000}]
  end


## Special achievements

  achievement do
    title 'Snail Walker'
    description 'Slower than a normal person and a cute Zombie. You must be a Snail Walker?!'
    points 42 # the answer to everything!
    validator 'AttributeValidator'
    sport 'Running'
    rules [
              {operator: '<=', attribute: 'length', value: 1000},
              {operator: '>', attribute: 'length', value: 0},
              {operator: '>', attribute: 'time', value: 60}
          ]
  end

  achievement do
    title 'Cute Zombie Walker'
    description 'Being a Zombie!'
    points 1000
    validator 'AttributeValidator'
    sport 'Running'
    rules [
              {operator: '<=', attribute: 'length', value: 2000},
              {operator: '>', attribute: 'length', value: 1000},
              {operator: '>', attribute: 'time', value: 60}
          ]
  end

  achievement do
    title 'Dangerous Zombie Walker'
    description 'Being a dangerous Zombie!'
    points 200
    validator 'AttributeValidator'
    sport 'Running'
    rules [
              {operator: '<=', attribute: 'length', value: 3000},
              {operator: '>', attribute: 'length', value: 2000},
              {operator: '>', attribute: 'time', value: 60}
          ]
  end

  achievement do
    title 'Really Dangerous Zombie Walker'
    description 'Being a really dangerous Zombie!'
    points 300
    validator 'AttributeValidator'
    sport 'Running'
    rules [
              {operator: '<=', attribute: 'length', value: 4000},
              {operator: '>', attribute: 'length', value: 3000},
              {operator: '>', attribute: 'time', value: 60}
          ]
  end

end
