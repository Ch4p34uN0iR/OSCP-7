#!/usr/bin/ruby
require 'Socket'

class PingSweep
  def initialize(address,fourthOctet)
    @ipv4  = address
    @octet = fourthOctet
  end

  def instructions
    if ARGV[0] == 'h' || ARGV[0] == '-h' || ARGV[0] == '--help'
      puts "Enter the top range of the 4th octet of the IP address to scan e.g 254"
    end
  end

  def generateUserIP
    ip    = IPSocket.getaddress(Socket.gethostname).split('.')
    @ipv4 = ip[0..2].join('.')

    puts "ip #{ip}"
    if ARGV[0].to_i >= 0 && ARGV[0].to_i < 255 && ARGV[0] != nil
      @octet = ARGV[0]
    else
      puts "must enter a range (0-254) -h for help"
    end
  end

  def ping
    # should look into creating multiple threads for a better/faster solution
    1.upto(@octet.to_i) {|oct|
      output = `ping -c 1 -t 1 #{@ipv4}.#{oct}|grep "bytes from"|cut -d" " -f 4|cut -d":" -f1`
      puts output if output.size != 0
    } unless @octet == 1
  end
end

# setting default octet to 1
pingSweep=PingSweep.new("IP",1)
pingSweep.instructions()
pingSweep.generateUserIP()
pingSweep.ping()
