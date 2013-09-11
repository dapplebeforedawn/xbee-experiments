#!/usr/bin/env ruby

require 'socket'
require 'optparse'
require './lib/options'
require './lib/data'

XBEE_PORT       = 3054
i               = 0

def counter i
  return '' if Options.get.hide_count
  "#{i.to_s.rjust(4, '0')}> "
end

def output msg
  if Eng.handle?
     Eng.new(msg)
   elsif Raw.handle?
     Raw.new(msg)
   else
     raise "That shouldn't happen"
   end
end

Socket.udp_server_loop(XBEE_PORT) do |msg, msg_src|
  i += 1
  puts "#{counter i}#{output(msg)}\r"
  STDOUT.flush # Without this we can't pickup the stdout when parent process is ruby
end
