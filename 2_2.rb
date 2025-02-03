# coding: utf-8
require 'open-uri'
require 'json'

id = ARGV[0]

uri = "https://ci.nii.ac.jp/ncid/#{id}.json"
URI.open(uri) do |f|
  data = JSON.parse(f.read)
  l = data["@graph"][0]["bibo:owner"]
  
  l.each do |i|
    name = i["foaf:name"]
    url = i["@id"]
    if url
      luri = url + ".json"
      URI.open(luri) do |lf|
        ldata = JSON.parse(lf.read)
        address = ldata["@graph"][0]["v:adr"]
        if address
          label = address["v:label"]
          puts "所蔵図書館:#{name}"
          puts "住所:#{label}"
          puts ""
        end
      end
    end
  end
end
