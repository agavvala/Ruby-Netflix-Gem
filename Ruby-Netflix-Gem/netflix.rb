require "net/http"
require "cgi"
require "base64"
require "hmac-sha1"               # make sure ruby-hmac gem is installed
require 'rexml/document'

module Netflix
  class API
    NETFLIX_URL = 'http://api.netflix.com/'
    OAUTH_VERSION= 1.0
    SIGNATURE_ALGORITHM = "HMAC-SHA1"

    attr_reader :service_consumer_key, :service_shared_secret

    # Using the API requires a developer account to be set up with Netflix
    # An account at Netflix is a combination of <consumer-key, secret-key>
    def initialize(service_consumer_key, service_shared_secret)
      @service_consumer_key = service_consumer_key
      @service_shared_secret = service_shared_secret
    end

    private
      # generate a random number to be used as nonce
      def nonce
        rand(1_500_000_000)
      end

      # url encode a string
      def e(value)
        CGI.escape(value)
      end

      # url timestamp within 5 minutes +/-
      def nonce_timestamp(tolerance = 5)
        Time.now.to_i + tolerance
      end

      # this method adds the signature to the parameter map
      def sign(method="GET", path="/", parameters={})
        # add special oauth parameters to the incoming parameter hash map
        parameters.merge!({
                       oauth_consumer_key: service_consumer_key,
                       oauth_version: OAUTH_VERSION,
                       oauth_signature_method: SIGNATURE_ALGORITHM,
                       oauth_timestamp: nonce_timestamp,
                       oauth_nonce: nonce
                     })
        puts parameters.parameter_string
        to_sign_string = "#{method}&#{e NETFLIX_URL}#{e path}&#{e parameters.parameter_string}"
        #puts ".OAuth Base String: "+to_sign_string
        signature = Base64.encode64(HMAC::SHA1.digest("#{service_shared_secret}&", to_sign_string))
        parameters[ :oauth_signature ] = e signature
      end

      # HTTP methods
      def get(path="/", parameters={})
        sign("GET", path, parameters)
        url_string = "#{NETFLIX_URL}#{path}?#{parameters.parameter_string}"
        url = URI::parse(url_string)
        http_response = Net::HTTP.start(url.host, url.port) { |http| http.get(url_string)}
        http_response
      end

    public
      def search_titles_by_people(term, start_index=0, max_results=25)
        get("catalog/people", { term: term, start_index: start_index, max_results: max_results})
      end

  end


end


# extend the Hash to include to_param string method
# a value string can also be a Hash
class Hash
  def parameter_string
    output_string = ''
    sort_by { |key, value | key} .each { |key, value| output_string += "#{key}=#{value}&" }  # create name=value strings connected by &
    output_string.chomp!("&")
  end
end