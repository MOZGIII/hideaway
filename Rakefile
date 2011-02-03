# -*- mode: ruby; -*-
require 'rake'
require 'mongo'
require 'json'
require 'server_config.rb'

# Load the config
ServerConfig.load 'rbircd.conf'

namespace :user do
	desc "Looks for a user by name in the database"
	task :show, :username do |t, args|

		username = args[:username] || ''

		db = Mongo::Connection.new(ServerConfig.mongodb_host).db(ServerConfig.mongodb_dbname)
		if db
			user = db.collection('users').find_one('username' => username)
			if user
				puts JSON.pretty_generate(user)
			else
				puts "No user found..."
			end
		else
			puts "Could not connect to database"
		end
	end
	desc "Add a user given a username and password"
	task :add, :username, :password do |t,args|

		username = args[:username] || ''
		password = args[:password] || ''

		if username.empty? or password.empty?
			puts "username and password are required"
		else
			db = Mongo::Connection.new(ServerConfig.mongodb_host).db(ServerConfig.mongodb_dbname)
			if db
				user = db.collection('users').find_one('username' => username)
				if user
					puts "User already exists. Exiting..."
				else
					doc = {'username' => username, 'password' => Digest::SHA1.hexdigest(password)}
					db.collection('users').insert(doc)
					puts "User Added"
					Rake::Task['user:show'].execute({:username => username})
				end
			else
				puts "Could not connect to database"
			end
		end
	end
end
