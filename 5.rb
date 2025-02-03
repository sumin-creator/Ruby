# coding: utf-8
require 'open-uri'
require 'json'
require 'uri'
require 'cgi'

APP_ID = '使用するID'

def geocode(address)
  url = "https://map.yahooapis.jp/geocode/V1/geoCoder"
  query = URI.encode_www_form(
    appid: APP_ID,
    output: 'json',
    query: address
  )
  url2 = "#{url}?#{query}"
  se = URI.open(url2).read
  data = JSON.parse(se)

  if data['Feature'] && data['Feature'].any?
    pc = data['Feature'][0]['Geometry']['Coordinates']
    keido, ido = pc.split(',').map(&:to_f)
    [ido, keido]
  else
    nil
  end
end

def make_html(locations)
  <<~HTML
    <!DOCTYPE html>
    <html lang="ja">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>地図表示 - 複数のライブラリ</title>
        <style>
            body {
                text-align: center;
                font-family: Arial, sans-serif;
            }
            .map-container {
                margin: 20px auto;
                border: 1px solid #ccc;
                padding: 10px;
                width: 80%;
            }
            .map {
                border: 1px solid #ccc;
                margin: 10px auto;
            }
            .info {
                margin-top: 10px;
                font-size: 1em;
                font-weight: bold;
            }
        </style>
    </head>
    <body>
        <h1>指定範囲内のライブラリ一覧</h1>
        #{locations.map { |location| html(location) }.join("\n")}
    </body>
    </html>
  HTML
end

def html(location)
  address, name, ido, keido, distance = location.values_at(:address, :name, :ido, :keido, :distance)
  <<~HTML
    <div class="map-container">
        <iframe
            class="map"
            width="800"
            height="600"
            frameborder="0"
            src="https://www.openstreetmap.org/export/embed.html?bbox=#{keido-0.01}%2C#{ido-0.01}%2C#{keido+0.01}%2C#{ido+0.01}&amp;layer=mapnik&amp;marker=#{ido}%2C#{keido}"
            allowfullscreen
        ></iframe>
        <div class="info">
            <p>住所: #{address}</p>
            <p>名前: #{name}</p>
            <p>緯度: #{ido}</p>
            <p>経度: #{keido}</p>
            <p>距離: #{distance.round(2)} m</p>
        </div>
    </div>
  HTML
end

def dist(coord1, coord2)
  deg = Math::PI / 180
  rm = 6371e3

  lat1, lon1 = coord1
  lat2, lon2 = coord2

  dlat = (lat2 - lat1) * deg
  dlon = (lon2 - lon1) * deg

  lat1_rad = lat1 * deg
  lat2_rad = lat2 * deg

  a = Math.sin(dlat / 2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon / 2)**2
  c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

  rm * c
end

if ARGV.size < 3
  puts "Usage: ruby script.rb <現在地> <NCID> <距離(m)>"
  exit
end

location = ARGV[0]
id = ARGV[1]
max_distance = ARGV[2].to_f

coord = geocode(location)

if coord.nil?
  puts "正しい地名を入力してください。"
  exit
end

uri = "https://ci.nii.ac.jp/ncid/#{id}.json"
all = []

URI.open(uri) do |f|
  data = JSON.parse(f.read)
  libraries = data["@graph"][0]["bibo:owner"]

  libraries.each do |library|
    name = library["foaf:name"]
    url = library["@id"]

    next unless url

    luri = "#{url}.json"
    URI.open(luri) do |lib_file|
      ldata = JSON.parse(lib_file.read)
      address = ldata["@graph"][0]["v:adr"]

      next unless address

      label = address["v:label"]
      lcoord = geocode(label)

      if lcoord
        distance = dist(coord, lcoord)

        if distance <= max_distance
          puts "#{name} (#{label}) は #{distance.round(2)}m の範囲内にあります。"
          all << {
            address: label,
            name: name,
            ido: lcoord[0],
            keido: lcoord[1],
            distance: distance
          }
        else
          puts "#{name} (#{label}) は指定範囲外です。"
        end
      else
        puts "#{label} の地図情報を取得できませんでした。"
      end
    end
  end
end

if all.any?
  html = make_html(all)
  File.write("5.html", html)
  puts "'5.html' に保存しました。"
else
  puts "指定範囲内にライブラリは見つかりませんでした。"
end
