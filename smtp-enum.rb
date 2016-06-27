#!/usr/bin/ruby
# smtp-enum.rb -x VRFY,EXPN -t 192.168.90.143 -U "/root/users.txt" -p 25,114
# smtp-enum.rb -H "/root/hosts.txt" -u root
# smtp-enum.rb -v -x VRFY,EXPN -H "/root/hosts.txt" -U "/root/users.txt" -p 25,114,139,200

require 'optparse'
require 'socket'

options = {:host => nil, :hosts => nil, :cmds => nil, :ports => nil, :user => nil, :users => nil}
summary = ""

ARGV.push("-h") if ARGV.empty?
parser = OptionParser.new do|opts|
  opts.banner = "[+] Usage: smtp-enum.rb [options]\n" \
                "[+] Ex: smtp-enum.rb -t 192.168.190.40 -U users.txt"
  opts.on("-t", "--host ip", "target ip address") do |ip|
    options[:host] = ip
  end

  opts.on("-H", "--Hosts ips", "file of target ip addresses") do |ips|
    options[:hosts] = ips
  end

  opts.on("-x", "--cmd x,y", Array, "comma seperated list of smtp commands VRFY,EXPN - default VRFY") do |cmd|
    options[:cmds] = cmd
  end

  opts.on("-p","--ports x,y",Array, "port or ports to scan comma seperated - default 25") do |port|
    options[:ports] = port
  end

  opts.on("-u","--user username", "try one user") do |user|
    options[:user] = user
  end

  opts.on("-U","--users usernames", "file of usernames") do |users|
    options[:users] = users
  end
  
  opts.on("-v","--verbose", "display all output") do |v|
    options[:verbose] = v
  end

  opts.on('-h', '--help', 'displays Help') do
    puts opts
    exit
  end
  summary = opts.summarize
end.parse!


@host    = options[:host]
@hosts   = options[:hosts]
@cmds    = options[:cmds]  || ['VRFY']
@ports   = options[:ports] || [25]
@user    = options[:user]
@users   = options[:users]
@verbose = options[:verbose]
@strings = []
@results = []

def build_cmd()
  if @users
    File.readlines("#{@users}").each do |user|
      @cmds.each{ |cmd| @strings << "#{cmd} #{user.chomp}\r\n" }
    end
  elsif @user
      @cmds.each{ |cmd| @strings << "#{cmd} #{@user}\r\n" }
  else
    puts "[@] Err: must provide 1 user (-u ultralaser) or 1 file of newline delimitted users (-U doctordoom.txt)"
    exit(1)
  end
end

def request()
  puts
  @ports.each{|port|
    if @host
      begin
        @strings.each{|str|
          @client = TCPSocket.new("#{@host}", port)
	    @client.write(str)
            @client.close_write
            @results << @client.read
        }
	    puts "CONNECTION -- #{@host.chomp} -- #{port} -- SUCCEEDED"
      rescue => ex
	puts "CONNECTION -- #{@host} -- #{port} -- FAILED"
        #{ex.class}: #{ex.message}"
      end
    elsif @hosts
      File.readlines("#{@hosts}").each do |host|
        begin
          @strings.each{|str|
            @client = TCPSocket.new("#{host}", port)
            @client.write(str)
            @client.close_write
            @results << @client.read
          }
	    puts "CONNECTION -- #{host.chomp} -- #{port} -- SUCCEEDED"
        rescue => ex
	  puts "CONNECTION -- #{host.chomp} -- #{port} -- FAILED"
          #{ex.class}: #{ex.message}"
        end
      end
    end
  } if @ports
end

def format_output()
  puts "\n============== RESULTS ==============\n\n"
  @results.each do |result|
    if result.include?('252') || result.include?('250')
      puts "[+] #{result.chomp} exists"
    end unless @verbose
    if @verbose
      puts @results.join("\r\n[+]")
    end
  end
  puts
end

build_cmd
request
format_output
