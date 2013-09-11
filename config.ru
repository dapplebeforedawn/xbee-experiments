class String; alias :each :each_line; end

VALUES  = [ 'UNINITIALIZED' ]
rd, wr  = IO.pipe

Kegmotron = ->(env) do
  [ 200, {'Content-Type'=>'text/plain'}, VALUES.last ] 
end

puts "[Setting up Xbee Read Pipe]"
Thread.new do
  rd.each_line { |line| VALUES << line }
end

puts "[Spawning Xbee Process]"
spawn "./xbee-hex.rb -w0.97 -e100 -z104", out: wr

run  Kegmotron
