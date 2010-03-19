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

def reload!
	load 'ircserver.rb'
	load 'ircchannel.rb'
	load 'ircclient.rb'
	load 'ircconnection.rb'
	load 'lineconnection.rb'
end
reload!

class ServerConfig
	def self.load filename
		@yaml = YAML.load File.open(filename)
	end
	
	# Shorter way to access data
	def self.method_missing m, *args, &blck
		super unless @yaml.has_key?(m.to_s.gsub('_', '-'))
		raise ArgumentError, "wrong number of arguments (#{args.length} for 0)" if args.any?
		@yaml[m.to_s.gsub('_', '-')]
	end
end

# Load the config
ServerConfig.load 'rbircd.conf'

# Daemons.daemonize
$server = IRCServer.new ServerConfig.server_name

EventMachine::run do
	ServerConfig.listens.each do |listener|
		EventMachine::start_server listener['interface'], listener['port'].to_i, IRCConnection, $server
	end
	
	EventMachine::add_periodic_timer 60 do
		$server.socks.each do |conn|
			conn.send_line "PING :#{$server.name}"
		end
	end
end
