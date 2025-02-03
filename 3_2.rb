# coding: utf-8
require 'open-uri'
require 'json'
require 'uri'
require 'cgi'

class YOLP
  def initialize(app_id = "dj0zaiZpPWxPNFl0STFYSDE0cSZzPWNvbnN1bWVyc2VjcmV0Jng9Njg-")
    @app_id = app_id
    @rx = 6378137.000
    @ry = 6356752.314245
    @e = Math.sqrt(1 - (@ry / @rx)**2)
    @rdRatio = Math::PI / 180
  end

  def coordinate(address)
    coord = nil
    URI.open("https://map.yahooapis.jp/geocode/V1/geoCoder?query=#{CGI.escape(address)}&appid=#{@app_id}&output=json") do |f|
      json = JSON.parse(f.read)
      if json['ResultInfo']['Count'] > 0
        coord = json['Feature'][0]['Geometry']['Coordinates'].split(/,/)
        if coord.length == 2
          coord[0] = coord[0].to_f
          coord[1] = coord[1].to_f
        end
      end
    end
    coord
  end

  def distance(coord1, coord2)
    rlon1 = @rdRatio * coord1[0]
    rlon2 = @rdRatio * coord2[0]
    dx = rlon1 - rlon2
    rlat1 = @rdRatio * coord1[1]
    rlat2 = @rdRatio * coord2[1]
    dy = rlat1 - rlat2
    p = (rlat1 + rlat2) / 2
    w = Math.sqrt(1 - (@e * Math.sin(p))**2)
    m = @rx * (1 - @e**2) / (w**3)
    n = @rx / w
    Math.sqrt((dy * m)**2 + (dx * n * Math.cos(p))**2)
  end
end

if ARGV.empty?
  puts "現在地を入力してください。"
  exit
end

location = ARGV[0]

yolp = YOLP.new
tcoord = yolp.coordinate(location)

if tcoord.nil?
  puts "正しい地名を入力してください。"
  exit
end

id = ARGV[1]

uri = "https://ci.nii.ac.jp/ncid/#{id}.json"
URI.open(uri) do |f|
  data = JSON.parse(f.read)
  l = data["@graph"][0]["bibo:owner"]

  dist = []

  l.first(20).each do |i|
    name = i["foaf:name"]
    url = i["@id"]

    if url
      luri = url + ".json"
      URI.open(luri) do |lf|
        ldata = JSON.parse(lf.read)
        address = ldata["@graph"][0]["v:adr"]

        if address
          label = address["v:label"]
          lm = yolp.coordinate(label)

          if lm
            ido, keido = lm
            ldistance = yolp.distance(tcoord, lm)
            dist << { name: name, distance: ldistance.round(2) }
          else
            dist << { name: name, distance: 10000000 }
            puts "住所 #{label} の地図はありません。最大距離として 10,000km を使用します。"
          end
        end
      end
    end
  end

  sort = dist.sort_by { |lib| lib[:distance] }

  puts "現在地（#{location}）から近い順に図書館を表示します:"
  sort.each do |lib|
    puts "#{lib[:name]} - 距離: #{lib[:distance]} メートル"
  end
end
