# Hideaway #

An IRC Server aimed for small companies and teams. Designed for
authenticating users, controlling their access to the server/channels.

This project was forked from the rbircd project on Github. Thanks to 
danopia for starting it!

## Database ##

Hideaway uses MongoDB as it's backend. It stores all authentication
details for users, as well as all the channel logs.

## Installation ##

Hideaway requires the following gems:

* eventmachine
* daemons
* mongo

Copy rbircd.conf.dist to rbircd.conf and modify to taste. Run ircd.rb to
start it up.

## TODO ##

* Crypt passwords
* Add allowed channels for users
* Ability to spit back logs to people who were offline
* Ping timeouts
* Join channel list
* Modes
* Code needs to be split up across files
* Check for params to reduce errors
* Check for chanop etc. before accepting modes, topics
* INVITE
* AWAY
