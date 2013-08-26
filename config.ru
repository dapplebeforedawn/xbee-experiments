require 'stringio'
require 'socket'

SOCKET_PATH     = 'tmp/socket.sock'
@current_value  = [ 'UNINITIALIZED' ]

Kegmotron = ->(env) do
  [ 200, {'Content-Type'=>'text/plain'}, @current_value ] 
end

puts "[Setting up Xbee Socket Server]"
Thread.new do
  Socket.unix_server_loop(SOCKET_PATH) do |sock, client_addrinfo|
    sock.lines do |sock|
      @current_value = [ sock ]
    end
  end 
end

puts "[Spawning Xbee Process Listener]"
Thread.new do
  sleep 1
  Socket.unix(SOCKET_PATH) do |sock|
    pid = spawn "./xbee-hex.rb", out: sock
  end
end

run  Kegmotron


# I feel like there should be a way to do this without all
# the ceremony around the socket. Not working yet.
#
#out_pipe, in_pipe = IO.pipe

#Thread.new do
  #pid = spawn './xbee-hex.rb', out: in_pipe
#end

#Thread.new do
  #while true do
    #puts out_pipe.read
    #@current_value = StringIO.new(out_pipe.read)
  #end
#end
