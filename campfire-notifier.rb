#! /usr/bin/env ruby

require 'net/http'

DEVMOTRON_URL = "cm-devmotron.herokuapp.com"

def make_status(raw_status)
  "{\"level\":  #{raw_status}}"
end

def notify(status)
  req      = Net::HTTP::Post.new('/keg_status', {'Content-Type' => 'application/json'})
  req.body = make_status(status)
  response = Net::HTTP.new(DEVMOTRON_URL).start {|http| http.request(req) }
end

rd, wr  = IO.pipe
spawn "./xbee-hex.rb -p -c", out: wr

puts "[Setting up Xbee Read Pipe]"
rd.each_line do |status_update|
  status_update.chomp!
  next unless Time.now.sec % 10
  puts status_update
  Thread.new { notify(status_update) }
end
