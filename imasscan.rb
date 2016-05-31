#! /usr/bin/ruby
# run masscan against targets and call nmap with found ports
require 'optparse'

options = {:ports => nil, :ip => nil}
summary = ""
ARGV.push('-h') if ARGV.empty?
parser = OptionParser.new do|opts|
	opts.banner = "Usage: imasscan.rb [options]"
	opts.on('-i', '--ip ip', 'ip address') do |ip|
		options[:ip] = ip;
    puts ip
	end

  opts.on("-p","--ports x,y", "-[a-z]", "Array", "Enter port or ports to scan comma seperated or range") do |port|
    puts port
    options[:ports] = port
  end

  opts.on('-h', '--help', 'Displays Help') do
		puts opts
		exit
	end
  summary = opts.summarize
end.parse!

def run_masscan
  system "bash", "-c", "masscan -p#{:ports} #{:ip}"
end

def run_nmap

end

run_masscan
