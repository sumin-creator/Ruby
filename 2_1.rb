# coding: utf-8
require "open-uri"
require 'json'
require 'cgi'

str = ARGV[0]

ID = "jsqAbSa3aKX49y0tRjEY"
n = 1
URI.open("https://ci.nii.ac.jp/books/opensearch/search?title=#{CGI.escape(str)}&format=json&appid=#{ID}") do |f|
  x = JSON.parse(f.read)
  pp = x["@graph"][0]["items"]

  pp.each { |p|
    puts "#{n} #{p["title"]} (#{p["@id"]})"
    puts ""
    n += 1
  }
end
