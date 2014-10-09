# Teste para Locaweb

require 'oauth'
require 'net/http'
require 'uri'
require 'json'
require 'yaml'

config = YAML::load_file "config.yml"

def prepare_access_token(oauth_token, oauth_token_secret, api_key, api_secret)
    consumer = OAuth::Consumer.new(api_key, api_secret, { :site => "https://api.twitter.com", :scheme => :header })
     
    # now create the access token object from passed values
    token_hash = { :oauth_token => oauth_token, :oauth_token_secret => oauth_token_secret }
    access_token = OAuth::AccessToken.from_hash(consumer, token_hash )
 
    return access_token
end

access_token = prepare_access_token(config['access_token'], config['access_token_secret'], config['api_key'], config["api_secret"])

API_HOST       = "api.twitter.com"
API_BASE_URL   = "https://#{API_HOST}"
path           = "/1.1/search/tweets.json?q=%23locaweb&count=100&result_type=recent"
uri = URI.parse "#{API_BASE_URL}#{path}"
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
res = access_token.request(:get,uri.request_uri)

json = JSON.parse(res.body)
mentions = Array.new

json["statuses"].each do |item|
  if item["in_reply_to_user_id"] == nil
    mentions.push(item)
  end
end

items = mentions.sort_by! { |a| -a["user"]["followers_count"] }

line = "-------------------------------------------------------------------------------------------------------------------------"
puts "Usuario |\t\tSeguidores |\t\tConteudo |\t\tData/Hora"
puts line

items.each do |data|
  link = "https://twitter.com/" + data["user"]["screen_name"] + "/status/" + data["id_str"]
  puts data["user"]["screen_name"] << " |\t\t" << data["user"]["followers_count"].to_s << " |\t\t" << data["text"] << " |\t\t" << data["created_at"][0,19] << " " << link
  puts line
end

