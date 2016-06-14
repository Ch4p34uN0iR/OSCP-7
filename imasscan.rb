#! /usr/bin/ruby
require 'optparse'

options = {:ports => nil, :ip => nil, :rate => nil, :inet => nil}
summary = ""

ARGV.push("-h") if ARGV.empty?
parser = OptionParser.new do|opts|
	opts.banner = "Usage: imasscan.rb [options]"
	opts.on("-i", "--ip x,y", "ip address or range/24") do |ip|
		options[:ip] = ip
	end

  opts.on("-r", "--rate rate", "masscan rate") do |rate|
		options[:rate] = rate
	end
  
  opts.on("-x", "--inet interface", "interface") do |inet|
		options[:inet] = inet
	end

  opts.on("-p","--ports x,y", "-[a-z]", "Enter port or ports to scan comma seperated or range") do |port|
    options[:ports] = port
  end

  opts.on('-h', '--help', 'Displays Help') do
		puts opts
		exit
	end
  summary = opts.summarize
end.parse!

@rate   = options[:rate] || '10000'
@ip     = options[:ip]
@ports  = options[:ports]
@inet   = options[:inet]
@portno = []
@output = []

def run_masscan
  results = %x[masscan #{@ip} --interface #{@inet} -p#{@ports} --rate=#{@rate}]
  results.scan(/(.+)$/).flatten.each{|str|@portno << str.partition('/').first.split(" ").last}
end

def run_nmap
  results = %x[nmap -sV -v -A -T4 #{@ip} -p #{@portno.join(',')}]
  @output.push(results)
end

def format_output
  puts @output.join.partition('Nmap scan report for ').last.partition('TRACEROUTE').first
end

run_masscan
run_nmap
format_output
