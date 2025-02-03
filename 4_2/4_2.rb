# coding: utf-8
require 'sinatra'
require 'open-uri'
require 'json'
require 'cgi'

ID = "使用するID"

get '/' do
  erb :index
end

get '/results' do
  title = params[:title]
  @results = search_books(title)
  erb :results
end

get '/libraries/:id' do
  @libraries = get_libraries_by_id(params[:id])
  erb :library_details
end

def get_libraries_by_id(id)
  uri = "https://ci.nii.ac.jp/ncid/#{id}.json"
  response = URI.open(uri).read
  data = JSON.parse(response)

  library_info = data["@graph"][0]["bibo:owner"]
  libraries = []
  library_info.first(20).each do |library|
    library_name = library["foaf:name"]
    library_url = library["@id"]
    library_address = fetch_library_address(library_url) if library_url

    if library_address
      lm = geocode(library_address)
      ido, keido = lm ? lm : [nil, nil]
      libraries << { name: library_name, address: library_address, ido: ido, keido: keido }
    end
  end

  libraries
end

def search_books(title)
  url = "https://ci.nii.ac.jp/books/opensearch/search?title=#{CGI.escape(title)}&format=json&appid=#{ID}"
  response = URI.open(url).read
  data = JSON.parse(response)

  if data["@graph"] && data["@graph"][0] && data["@graph"][0]["items"]
    data["@graph"][0]["items"].map do |item|
      {
        title: item["title"],
        id: item["@id"].split("/").last
      }
    end
  else
    []
  end
end

get '/libraries/:id' do
  @libraries = get_libraries_by_id(params[:id])
  erb :library_details
end

def get_book_details(book_id)
  book_url = "https://ci.nii.ac.jp/ncid/#{book_id}.json"
  response = URI.open(book_url).read
  data = JSON.parse(response)

  library_info = data["@graph"][0]["bibo:owner"]
  libraries = []

  if library_info
    library_info.each do |library|
      library_name = library["foaf:name"]
      library_url = library["@id"]
      library_address = fetch_library_address(library_url) if library_url
      if library_address
        libraries << { name: library_name, address: library_address }
      end
    end
  end

  { book_id: book_id, libraries: libraries }
end

def fetch_library_address(library_url)
  begin
    luri = "#{library_url}.json"
    response = URI.open(luri).read
    data = JSON.parse(response)
    address = data["@graph"][0]["v:adr"]
    address ? address["v:label"] : nil
  rescue OpenURI::HTTPError => e
    nil
  end
end

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
