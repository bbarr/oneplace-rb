require "rubygems"
require "httparty"
require "digest/md5"
require "net/http"
require "cgi"
require "json"

class OnePlace
  include HTTParty
  base_uri 'poic.herokuapp.com'

  def initialize pub, priv
    @public_key = pub
    @private_key = priv
  end

  def details source, ids, props
    request "/places/#{source}", { ids: ids.join(','), props: props.join(',') }
  end

  def search source, terms, props
    request "/places/#{source}", { terms: URI.escape(JSON.generate(terms), Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")), props: props.join(',') }
  end

  def request url, params

    now = Time.now.to_i

    fullParams = params.merge({
      timestamp: now,
      authHash: Digest::MD5.hexdigest(now.to_s + @private_key),
      publicKey: @public_key
    })

    uri = URI('poic.herokuapp.com' + url)
    uri.query = URI.encode_www_form(fullParams)

    res = Net::HTTP.get_response(uri) 
  end
end
