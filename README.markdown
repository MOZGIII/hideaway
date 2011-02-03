# Hideaway #

An IRC Server aimed for small companies and teams. Designed for
authenticating users, controlling their access to the server/channels.
It's written in Ruby, and based on the awesome EventMachine networking
library.

This project was forked from the rbircd project on Github. Thanks to 
danopia for starting it!

## Database ##

Hideaway uses MongoDB as it's backend. It stores all authentication
details for users, as well as all the channel logs and other details. While
this may be modified at some point to allow for other databases, it's not
in the immediate roadmap, as it serves all of the needs of the project
without too much trouble.

## Installation ##

Hideaway requires the following gems:

* eventmachine
* daemons
* mongo

Users are stored in the users collection in mongodb. The passwords are
simply a sha1 hashed string. The easiest way to hash it is to use:

	echo -n "blah" | shasum

Which will produce:

	5bf1fd927dfb8679496a2e6cf00cbe50c1c87145

Now go into the mongo shell and do the following:

	$ mongo
	MongoDB shell version: 1.6.5
	connecting to: test
	> use rbircd
	switched to db rbircd
	> db.users.insert({username: "test", password: "5bf1fd927dfb8679496a2e6cf00cbe50c1c87145", allow_channels: ['*']})

If you now look, you'll see the user is created:

	> db.users.find()
	{ "_id" : ObjectId("4d4a91d1595c4e3b7721d196"), "username" : "test",
		"allow_channels" : [ "*" ], "password" : "5bf1fd927dfb8679496a2e6cf00cbe50c1c87145" }
	
*(We'll setup a rake task to add/remove users and other settings in the
future)*

Copy rbircd.conf.dist to rbircd.conf and modify to taste. Run ircd.rb to
start it up.

## TODO ##

* <strike>Crypt passwords</strike>
* Add allowed channels for users
* Ability to spit back logs to people who were offline
* Add the concept of groups for permissions
* Setup Rakefile for common tasks and maintenance
* Ping timeouts
* Join channel list
* Modes
* Code needs to be split up across files
* Check for params to reduce errors
* Check for chanop etc. before accepting modes, topics
* INVITE
* AWAY
