#!/usr/bin/env ruby
# encoding: UTF-8
# ruby 2.0.0p598 (2014-11-13 revision 48408) [x86_64-linux]

def parse(requests)
  all = []
  requests.each do |request|
    r = {}
    if request =~ /^-+/

      r['ips'] = nil
      request = request.gsub('- - -','')
      rest = request.strip
      tmp = rest.split(' ')

      r['uri'] = tmp[3]
      r['code'] = tmp[5]
      r['size'] = tmp[6]
      
    else

      request =~ /(^([\d\.\ \,])+)(.+)/
      r['ips'] = $1.split(',').map {|i| i.strip}
      rest = $3.strip
      tmp = rest.split(' ')

      r['uri'] = tmp[5]
      r['code'] = tmp[7]
      r['size'] = tmp[8]

    end
    all << r
  end

  all

end

requests = parse(File.readlines('image-access.log'))
# How many requests were successful? 
successfull_request = requests.select { |h| h['code'].to_i < 400 }

puts "Total requests: #{requests.count}"
puts "Succesfull requests: #{successfull_request.count}"

# Unsucessfull requests?
unsuccessfull_request = requests.select { |h| h['code'].to_i > 400 }
puts "Unsuccesfull requests: #{unsuccessfull_request.count}"
unsuccessfull_request.each do |r|
  puts "#{' '*3} uri: #{r['uri']} error_code: #{r['code']}"
end

# Unique Ip's
ips = []
requests.each {|h| ips << h['ips'][0] if h['ips'] != nil }
puts "Unique Ip's: #{ips.uniq.count}"

# Largest object served
larger_object_size = -1
larger_object = nil
requests.each do |h|
  size = h['size'].to_i
  obj = h
  if larger_object_size < size
    larger_object_size = size
    larger_object = h
  end
end
puts "Larger object is: #{larger_object}"

# Average object size
total = 0
requests.each {|h| total += h['size'].to_i }
average_object_size = total / requests.count

puts "Average object size: #{average_object_size}"
