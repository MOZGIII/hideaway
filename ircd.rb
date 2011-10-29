#!/usr/bin/env ruby

# Copyright (c) 2009 Daniel Danopia
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of Danopia nor the names of its contributors may be used
#   to endorse or promote products derived from this software without specific
#   prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

require 'rubygems'
require 'yaml'
require 'daemons'
require 'eventmachine'
require 'server_config.rb'

def reload!
	load 'ircserver.rb'
	load 'ircchannel.rb'
	load 'ircclient.rb'
	load 'lineconnection.rb'
end
reload!

# Load the config
ServerConfig.load 'rbircd.conf'

# Daemons.daemonize
server = IRCServer.new ServerConfig.server_name

# Are we db logging?
if ServerConfig.mongodb
	require 'mongo'
	db = Mongo::Connection.new(ServerConfig.mongodb_host, ServerConfig.mongodb_port).db(ServerConfig.mongodb_dbname)
	if ServerConfig.has_key?('mongodb-username') and ServerConfig.has_key?('mongodb_password')
		db.authenticate(ServerConfig.mongodb_username, ServerConfig.mongodb_password)
	end
	server.set_db db
	server.set_db_logging ServerConfig.mongodb_logging
	server.set_require_login ServerConfig.mongodb_users_req_login
end

EventMachine::run do
	ServerConfig.listens.each do |listener|
		EventMachine::start_server listener['interface'], listener['port'].to_i, IRCClient, server
	end
	
	EventMachine::add_periodic_timer 60 do
		server.clients.each do |conn|
			conn.send nil, :ping, server.name
		end
	end
	
	puts "Ready."
end
