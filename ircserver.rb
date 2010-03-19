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

class IRCServer
  attr_accessor :debug, :clients, :channels, :name, :socks, :running

  def initialize(name=nil)
    @debug = true
    @clients = []
    @channels = []
    @name = name
    @socks = []
    @running = false
  end

  def log(msg)
    puts "[#{Time.new.ctime}] %s" % msg
  end
  def log_nick(nick, msg)
    log "#{@host}:#{@port} #{nick}\t%s" % msg
  end

  def remove_client(client)
    remove_sock client.io
  end
  def remove_sock(sock)
    @socks.delete sock
    @clients.delete sock.client
  end

  # Helper socks for client instances to use

  def validate_nick(nick)
    nick =~ /^[a-zA-Z\[\]_|`^][a-zA-Z0-9\[\]_|`^]{0,#{ServerConfig.max_nick_length.to_i - 1}}$/
  end
  def validate_chan(channel)
    channel =~ /^\#[a-zA-Z0-9`~!@\#$%^&*\(\)\'";|}{\]\[.<>?]{0,#{ServerConfig.max_channel_length.to_i - 2}}$/
  end
end