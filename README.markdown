# Keg-motron
> Experiments in hardware with the xbee `xb24-wfpit-001`

## USING THIS REPOSITORY
1. Using the other sections of this README get your xbee working
1. See a hex dump for your xbee's UDP transmission: `./xbee-hex.rb`

  > Can I have that as a webserver?
  - Yes, `rackup config.ru`

## JOINING A WIFI NETWORK
Inside `screen /dev/tty.usbxxxx 9600`
````
+++
ATID <your-network-ssid>  <cr>  # Set the network you want xbee to join
ATAH 2                    <cr>  # "Infrastructure" network is your normal at-home wifi setup
ATIP 1                    <cr>  # Use TCP instead of UDP
ATMA 0                    <cr>  # Use DHCP
ATEE 2                    <cr>  # Use WPA2 security
ATPK <your-wifi-password> <cr>  # Your network password
ATWR                      <cr>  # Save the settings
ATAC                      <cr>  # Make it so
````
If check your routers connected hosts, you should see the xbee


## EXAMPLE TIME

### Inside `screen /dev/tty.usbxxxx 9600`
````
+++
ATMY   <cr>  # Get the IP assigned to you
ATC0 8 <cr>  # Set the port to 8 (note that's a zero not a letter)
ATAP 0 <cr>  # Go to transparent mode
ATDO 0 <cr>  # Set the buffers to flush instantly
ATWR   <cr>  # Save the settings
ATAC   <cr>  # Make it so
````

### On the Mac 
`echo "HI Mark" | nc <xbee-ip> <xbee-port>`
  
**You should now see `Hi Mark` in your tty**

## TRANMITTING XBEE'S A/Ds VALUES
Turn on A/D data sampling
````
+++
ATIR  222 <cr>  # Sample about every 1/2 second (values are in hex)
ATD0  2   <cr>  # Set the AD0/DIO0 pin as an analog-in
ATWR      <cr>
ATAC      <cr>  # Make it so
````

Setup where to send the sampled data
````
+++
ATDL  <your-pc-ip>  <cr>  # Destination IP, port will always be 3054
ATWR                <cr>
ATAC                <cr>  # Make it so
````

## ANALYZING THE DATA

Data will be sent to the ip specified by `ATDL` on port 3054.  The xbee sends binary data encoded in a fixed-width format.  You can use this ruby code to visualize the incomming data:
````
#!/usr/bin/env ruby

require 'socket'

XBEE_PORT     = 3054
i             = 0

def counter i
  i.to_s.rjust(4, '0')
end

Socket.udp_server_loop(XBEE_PORT) do |msg, msg_src|
  i += 1
  puts "#{counter i} #{msg.inspect}"
end
````

## USING UDP TO SEND CONFIGURATION COMMANDS

`02 00 01 02 {MSB AT command} {LSB AT command} {your data (hex)}`

Example, set `ATDL` to `192.168.1.99`:

`02 00 01 02 64 6C 31 39 32 2E 31 36 38 2E 31 2E 39 39`

Put it in a file:

`printf "\x02\x00\x01\x02\x64\x6C\x31\x39\x32\x2E\x31\x36\x38\x2E\x31\x2E\x39\x39" > set_dl.bin`

Use `nc` to run it:

`nc -u <your-xbee-ip> 3054 < set_dl.bin`

> Note, this will not persist after a power cycle (use this method to set `ATWR` if you want that)

## NOTES:
- You need to install the [VCP driver](http://www.ftdichip.com/Drivers/VCP.htm) before you can use the exporer as a serial modem
- Using the [xbee with gnu-screen](http://www.hughesy.net/wp/arduino/xbee-and-macs-the-easy-way/)
- [common mistakes](http://answers.oreilly.com/topic/2475-the-most-common-xbee-mistakes/)
- [datasheet](http://ftp1.digi.com/support/documentation/90002124_C.pdf)
- [incompatability with USB explorers](http://www.digi.com/support/kbase/kbaseresultdetl?id=3325)
- The command mode (after `+++`) has a pretty quick timeout
- `AT` commands are not case sensitive (i.e. `at` works too)
- Debugging: Turn on all the ADCs and see if you can get a reading on any of them by shorting to ground through a small resistor.  I found that my explorer board was different from the [documentation](http://ftp1.digi.com/support/documentation/90002124_a.pdf) which was different from itself (pg.40 and pg.16)

