#!/usr/bin/ruby
# short nmap sweep version

if ARGV[0] == '-h' || ARGV[0] == '--help' || ARGV[0] == nil 
  puts "[+] sweep.rb RANGE - where RANGE is x-x" 
  exit
else
  puts "[+] sweeping #{ARGV[0]}"
  results= %x[nmap -v -sn #{ARGV[0]}]
end
  
results.split("\n").each{|li| puts "[+]" + li.partition("for").last if (li[/for/] && li.split(" ")[-2..-1].join != "[hostdown]")}
