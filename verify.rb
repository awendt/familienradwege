#!/usr/bin/env ruby

require 'optparse'

ACCEPTABLE_VARIATION_PERCENTAGE = 3

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby verify.rb [options]"

  opts.on("--generate", "Generate new fixtures") do |g|
    options[:generate] = g
  end
end.parse!

data_file = ARGV[0] || raise("Please pass a data file")
fixture_file = ARGV[1] || raise("Please pass a fixture file")

puts "Checking #{data_file} against #{fixture_file}…"

checks_out_of_range = 0

File.open(fixture_file, 'r') do |fixtures|
  fixtures.each_line do |line|
    key, value, lowerbound, upperbound = line.split(':').map(&:rstrip)

    count = `jq '.features | map(select(.properties.'#{key}' == "'#{value}'")) | length' #{data_file}`.to_i

    if options[:generate]
      new_lowerbound = count * (1 - ACCEPTABLE_VARIATION_PERCENTAGE / 100.0)
      new_upperbound = count * (1 + ACCEPTABLE_VARIATION_PERCENTAGE / 100.0)
      puts [key, value, new_lowerbound.round, new_upperbound.round].join(":")
    else
      puts " → Checking if #{count} #{key}=#{value} are within range (#{lowerbound}‥#{upperbound})…"
      checks_out_of_range += 1 if count <= lowerbound.to_i || count >= upperbound.to_i
    end
  end
end

exit checks_out_of_range
