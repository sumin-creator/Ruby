# coding: utf-8
require 'sinatra'
require 'open-uri'
require 'json'
require 'uri'

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
            <p>緯度: #{ido}</p>
            <p>経度: #{keido}</p>
        </div>
    </body>
    </html>
  HTML
end

get '/' do
  erb :index
end

post '/search' do
  id = params[:id]
  
  uri = "https://ci.nii.ac.jp/ncid/#{id}.json"
  response = URI.open(uri).read
  data = JSON.parse(response)
  l = data["@graph"][0]["bibo:owner"]
  
  libraries = []
  
  l.take(20).each do |i|
    name = i["foaf:name"]
    url = i["@id"]
    
    if url
      luri = url + ".json"
      library_data = JSON.parse(URI.open(luri).read)
      address = library_data["@graph"][0]["v:adr"]
      
      if address
        label = address["v:label"]
        lm = geocode(label)
        
        if lm
          ido, keido = lm
          libraries << { name: name, address: label, ido: ido, keido: keido, map_page: make(label, name, ido, keido) }
        else
          libraries << { name: name, address: label, ido: nil, keido: nil, map_page: nil }
        end
      end
    end
  end

  erb :results, locals: { libraries: libraries }
end

__END__

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>図書館検索</title>
</head>
<body>
    <h1>図書館検索</h1>
    <form action="/search" method="post">
        <label for="id">図書館IDを入力してください:</label>
        <input type="text" name="id" id="id" required>
        <button type="submit">検索</button>
    </form>
</body>
</html>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>検索結果</title>
</head>
<body>
    <h1>図書館検索結果</h1>
    <% if libraries.empty? %>
        <p>指定されたIDに対応する図書館は見つかりませんでした。</p>
    <% else %>
        <% libraries.each do |library| %>
            <h2><%= library[:name] %></h2>
            <p>住所: <%= library[:address] %></p>
            <% if library[:map_page] %>
                <iframe src="<%= library[:map_page] %>" width="800" height="600"></iframe>
            <% else %>
                <p>地図は表示できませんでした。</p>
            <% end %>
            <hr>
        <% end %>
    <% end %>
    <a href="/">再度検索する</a>
</body>
</html>
