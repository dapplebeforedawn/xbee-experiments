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

# Return true at most once every <interval> seconds
def clock(interval = 10)
  lambda do
    i = 0
    -> {
      time = (Time.new.to_f * 100).to_i
      seconds = (time -  time % interval) / 100
      if (seconds % interval).zero? && i.zero?
        i = i + 1
        return true
      elsif !(seconds % interval).zero?
        i = 0
      end
      return false
    }
  end
end

should_update_campfire = clock(10).call    # every 10 seconds
should_update_log      = clock(21600).call # twice per day

rd, wr  = IO.pipe
spawn "./xbee-hex.rb -p -c", out: wr

puts "[Setting up Xbee Read Pipe]"
rd.each_line do |status_update|
  status_update.chomp!

  log_line = "#{Time.now.to_i},#{status_update}"
  next unless should_update_campfire.call
  puts log_line
  Thread.new { notify(status_update) }

  next unless should_update_log.call
  Thread.new do
    File.open("keg-log.dat",  "a+") {|f| f.puts log_line }
  end

end
