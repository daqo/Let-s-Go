#Let's Go!
> A geographical transient social network powered by Objective-C and Ruby on Rails.

This project was done as a final course project for **iOS Development Course** during summer 2014.

# What's Let's Go?
* A social network
* A user can post his current status
  * The status will then be annotated on the map to the current user's geolocation
* We already have lots of different social networks. Why do we need another one?
  * Let's Go! is Transient
  * Let's Go! is Geographical
  * Let's Go! is Local
  * Let's Go! is Based on maps

## It's Transient
  * All the data will be wiped off of the servers in 20 minutes
  * Seeing it from this angle, it acts like Snapchat, with no permanent data

## It's Local
  * The users can see other people's statuses in their local vicinity which have been posted in the last 20 minutes
  * Presently the radius is 5 miles

# Frontend
  * It's written in Objective-C and is optimized for all iphones including iPhone 6
  * The code is located in iOSApp-Let'sGo Folder

# Backend
  * The backend server is written with Ruby on Rails
  * It doesn't use normal RoR, just Rails::API
    * Using it, we limit our Rails app to include only things necessary for API-driven apps
  * It's hosted on Heroku
    * ``http://lets-go.herokuapp.com``
  * The code is located in 'Rails backend' folder

## Public APIs
  * Registration
    * ``POST http://lets-go.herokuapp.com/users``
  * Login
    * ``POST http://lets-go.herokuapp.com/sessions``
  * Status List
    * ``POST http://lets-go.herokuapp.com/statuses/list``
  * Status Creation
    * ``POST http://lets-go.herokuapp.com/statuses/``

# More info?
See the files inside Final Docs folder.
