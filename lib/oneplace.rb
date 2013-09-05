require "rubygems"
require "httparty"
require "digest/md5"
require 'net/http'

class OnePlace
  include HTTParty
  base_uri 'localhost:3000'

  def initialize pub, priv
    @public_key = pub
    @private_key = priv
  end

  def place source, id, props
    request "/places/#{source}/#{id}", { props: props.join(',') }
  end

  def request url, params

    now = Time.now.to_i

    fullParams = params.merge({
      timestamp: now,
      authHash: Digest::MD5.hexdigest(now.to_s + @private_key),
      publicKey: @public_key
    })

    uri = URI('http://localhost:3000' + url)
    params = fullParams
    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri) 
  end
end
