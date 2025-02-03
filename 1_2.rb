# coding: utf-8
require 'open-uri'
require 'uri'
require 'json'

APP_ID = 'dj0zaiZpPWxPNFl0STFYSDE0cSZzPWNvbnN1bWVyc2VjcmV0Jng9Njg-'

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

def make(address, name, ido, keido)
  <<~HTML
    <!DOCTYPE html>
    <html lang="ja">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>地図表示</title>
        <style>
            body {
                text-align: center;
                font-family: Arial, sans-serif;
            }
            #map {
                border: 1px solid #ccc;
                margin: 20px auto;
            }
            #info {
                margin-top: 10px;
                font-size: 1.2em;
                font-weight: bold;
            }
        </style>
    </head>
    <body>
        <iframe
            id="map"
            width="800"
            height="600"
            frameborder="0"
            src="https://www.openstreetmap.org/export/embed.html?bbox=#{keido-0.01}%2C#{ido-0.01}%2C#{keido+0.01}%2C#{ido+0.01}&amp;layer=mapnik&amp;marker=#{ido}%2C#{keido}"
            allowfullscreen
        ></iframe>
        <div id="info">
            <p>住所: #{address}</p>
            <p>名前: #{name}</p>
        </div>
    </body>
    </html>
  HTML
end

puts "住所:"
address = gets.chomp
puts "名前:"
name = gets.chomp

pc = geocode(address)

if pc
  ido, keido = pc
  page = make(address, name, ido, keido)
  File.write('map.html', page)
  puts "HTMLファイル: map.html"
else
  puts "住所が見つかりません。"
end
