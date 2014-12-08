CyberCoachProject for the ASE Course 2014/15
--------------------------------------------
Note: to be improved

Developer Team:
- Sveta Krasikova
- Roman Kuepper
- Alexander Rueedlinger
- Stefan Wanzenried

Project Idea

The goal of this project is to create an application with the functionality important for doing sports activities.
The application should present a friendly interface to the CyberCoach service deployed on: http://diufvm31.unifr.ch:8090/CyberCoachServer/
Currently, we are focusing on implementing some functionality for motivating users to do sports.
In particular, we want to use gamification techniques to leverage users' desire to engage in sports activities, as the following user stories make clear.

User Stories

As a user, I should be able to
- earn points for doing sport activities(plus challenges & achievements)
- earn achievements for completing activities (Rookie runner, Intermediate runner, Pro runner, Usian Bolt)
- have challenges to solve (example: Run 5 km in 30 minutes, Run 100 km in one week etc.)
- share his progress/challenges on facebook and/or twitter
- see his progress plotted on a graph

<<<<<<< HEAD
## Documentation / User Guide
- [Home](https://github.com/Bergrebell/CyberCoach/wiki)
- [Facade Classes](https://github.com/Bergrebell/CyberCoach/wiki/Facade-Classes)
- [RestAdapter Classes](https://github.com/Bergrebell/CyberCoach/wiki/RestAdapter-Classes)

=======

## User Guide - Facade classes
###Problem Statement 
We have data on two places, namely on the cyber coach server and in the database of our rails application.

The facade classes are the glue that combines both data sources into a single data source.
###Querying
####Facade::User

If you want to get all users that are stored in the rails database you can use the following 'rails query':
```ruby
User.all
```

Here you get all users, but the user details such as real name are missing.

#####all example
In order to get the user details you can use the Facade::User class:

```ruby
Facade::User.query do
    User.all
end
```

The class method query in Facade::BaseFacade takes a block and executes it. 
The result of the block is returned to
Facade::BaseFacade#query class method and wraps the result into Facade objects. 
In that case the above query returns a list of user facade objects.

You can use any rails query method that you like except for aggregate functions like count etc.

#####find_by example
```ruby
Facade::User.query do
    User.find_by id: 2
end
```


#####where example
```ruby
Facade::User.query do
    User.where(id: 2)
end
```


####Facade::SportSession
#####all example
```ruby
Facade::SportSession.query do
    SportSession.all
end
```

#####where example
```ruby
Facade::SportSession.query do
    SportSession.where(user_id: 2).where(type: 'Running')
end
```

###Create, Update and Delete
####Facade::User
#####create & save
A user can be created using the Facade::User#create class method.
In order to create a user you need a hash with the following properties:

- username
- email
- real_name
- password
- password_confirmation

Example:

```ruby
 hash = {
        username: 'mydummy5',
        password: 'mydummy5',
        email: 'mydummy@mydummy.com',
        real_name: 'my dummy dummy',
        password_confirmation: 'mydummy5'
    }
    user = Facade::User.create hash
```

This will create a user facade object but the user is not yet persisted. For persisting a user we need to call
the instance method save.

Example:
```ruby
user.save
```
If persisting the user succeeds it returns the facade user object otherwise it returns false.


#####update
Assume you want to update the user with id 2.
```ruby
user = Facade::User.query do
   User.find_by id: 2
end
```

You can easily update a user using the update method. It takes as argument a hash with the following properties:

- real_name
- email
- password
- password_confirmation

All these properties are optional. In fact you could also pass an empty hash. In that case none of the properties will be changed.

Example:

```ruby
user.update({ real_name: 'Petter Muller', email: 'peter@peter.ch})
```

If updating a user succeeds the facade user is returned otherwise false.

#####delete
Deleting a user is pretty simple just call the method delete on a user facde object.

```ruby
user.delete
```
The delete method returns true if deleting succeeds otherwise false.

####Facade::SportSession
#####create
A sport session facade object can be created using the class method create.


It takes as argument a hash. The properties that are valid for creating a sport session depends on the type like Running, Cycling, Boxing or Soccer.



######Example Running
```ruby
 facade_user = Facade::User.query { User.find_by id: 2 }
 entry_hash = {
        :type =>  'Running',
        :course_length => 700,
        :number_of_rounds => 7,
        :entry_location => 'Bern',
        :comment => 'Some comment',
        :entry_duration => 10000,
        :entry_date => DateTime.now,
        :user => facade_user
    }
    sport_session = Facade::SportSession.create(entry_hash)
    sport_session.save
```


######Example Cycling
```ruby
 facade_user = Facade::User.query { User.find_by id: 2 }
 entry_hash = {
        :type =>  'Cycling',
        :course_length => 700,
        :number_of_rounds => 7,
        :entry_location => 'Bern',
        :comment => 'Some comment',
        :entry_duration => 10000,
        :entry_date => DateTime.now,
        :user => facade_user,
        :bicycle_type => 'blah'
    }
    sport_session = Facade::SportSession.create(entry_hash)
    sport_session.save
```

######Example Boxing
```ruby
 facade_user = Facade::User.query { User.find_by id: 2 }
 entry_hash = {
        :type =>  'Boxing',
        :number_of_rounds => 7,
        :round_duration => 10,
        :entry_location => 'Bern',
        :comment => 'Some comment',
        :entry_duration => 10000,
        :entry_date => DateTime.now,
        :user => facade_user
    }
    sport_session = Facade::SportSession.create(entry_hash)
    sport_session.save
```

######Example Soccer
```ruby
 facade_user = Facade::User.query { User.find_by id: 2 }
 entry_hash = {
        :type =>  'Soccer',
        :entry_location => 'Bern',
        :comment => 'Some comment',
        :entry_duration => 10000,
        :entry_date => DateTime.now,
        :user => facade_user
    }
    sport_session = Facade::SportSession.create(entry_hash)
    sport_session.save
```

#####update
Assume you want to update a running sport session. 

Updating a sport session can be done using the update method.
This method takes a hash as argument (see create examples for properties that are 'updatable':


```ruby
sport_session = Facade::SportSession.query { SportSession.find_by type: 'Running' }
new_values = { :type =>  'Running',
        :course_length => 700,
        :number_of_rounds => 7,
        :entry_location => 'Zuerich',
        :comment => 'Updated Some comment',
        :entry_duration => 10000,
        :entry_date => DateTime.now }
sport_session.update(new_values)
```

If updating succeeds true is returned otherwise false.


#####delete
For deleting a sport session just call the delete method on a sport session object.

```ruby
sport_session.delete
```

####Facade::Partnership
TODO
>>>>>>> 7ade5a2f0104293ce76db6fc90304898aaf86196
