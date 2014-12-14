SportsMate - ASE Course 2014/15
--------------------------------------------

![alt tag](https://raw.github.com/Bergrebell/CyberCoach/dev/sportsmate.png)



##Developer Team:
- Sveta Krasikova
- Roman Kuepper
- Alexander Rueedlinger
- Stefan Wanzenried

##Project Idea

The goal of this project is to create an application with the functionality important for doing sports activities.
The application should present a friendly interface to the CyberCoach service deployed on: http://diufvm31.unifr.ch:8090/CyberCoachServer/
Currently, we are focusing on implementing some functionality for motivating users to do sports.
In particular, we want to use gamification techniques to leverage users' desire to engage in sports activities, as the following user stories make clear.

##User Stories

As a user, I should be able to
- earn points for doing sport activities(plus challenges & achievements)
- earn achievements for completing activities (Rookie runner, Intermediate runner, Pro runner, Usian Bolt)
- have challenges to solve (example: Run 5 km in 30 minutes, Run 100 km in one week etc.)
- share his progress/challenges on facebook and/or twitter
- see his progress plotted on a graph

##Installation
```
git clone https://github.com/Bergrebell/CyberCoach.git
```

Install bundler:
```
gem install bundler
```

Resolve the project dependencies:
```
bundle install
```

Create database and insert necessary data:
```
rake db:migrate
rake db:seed
rake achievements:update
```

```
rails s
```

##Deployed application on heroku

```
https://radiant-depths-9885.herokuapp.com/
```

##Backend / Gpx file reader
For more details see:

* Coach4rb - CyberCoach Backend
 * [coach4rb github](https://github.com/lexruee/coach4rb)
 * [Rubygem website](http://rubygems.org/gems/coach4rb)
 * [Documentation](http://lexruee.github.io/coach4rb/doc/frames.html#!file.README.html)
* GpxRuby - GPX File Reader
 * [gpx_ruby github](https://github.com/lexruee/gpx_ruby)
 * [Rubygem website](http://rubygems.org/gems/gpx_ruby)
 * [Documentation](http://lexruee.github.io/gpx_ruby/doc/frames.html#!file.README.html)
