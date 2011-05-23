require "net/http"
require "cgi"
require "base64"
require "hmac-sha1" # make sure ruby-hmac gem is installed
require 'rexml/document'
require "xml/mapping"
require_relative "netflix-object-xml-mapping.rb"
require_relative "extras"

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

    # get document root
    def doc_root(response)
      body = response.body.gsub(/^<\?xml version\="1\.0" standalone\="yes"\?>/, "") # this line was giving us grief with REXML
      REXML::Document.new(body).root
    end

    # get object list
    def get_object_list(class_name, response)
       Netflix.const_get(class_name).send('load_from_xml', doc_root(response))
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
      #puts parameters.parameter_string
      to_sign_string = "#{method}&#{e NETFLIX_URL}#{e path}&#{e parameters.parameter_string}"
      #puts ".OAuth Base String: "+to_sign_string
      signature = Base64.encode64(HMAC::SHA1.digest("#{service_shared_secret}&", to_sign_string))
      parameters[:oauth_signature] = e signature
    end

    # HTTP methods
    def get(path="/", parameters={})
      sign("GET", path, parameters)
      url_string = "#{NETFLIX_URL}#{path}?#{parameters.parameter_string}"
      url = URI::parse(url_string)
      http_response = Net::HTTP.start(url.host, url.port) { |http| http.get(url_string) }
      http_response
    end

    public
    # Search for people by some part of their name (term)
    def search_people(term, start_index=0, max_results=25)
      get_object_list "CatalogTitles", get("catalog/people", {term: term, start_index: start_index, max_results: max_results})
    end

    # Get a person details by the person/person-id URL
    def get_person_by_id(person_id)
      get_object_list "Person", get("catalog/people/#{person_id}")
    end

    def search_title(search_term, start_index=0, max_results=10)
      get_object_list "People", get("catalog/titles", {term: search_term, start_index: start_index, max_results: max_results})
    end

  end


end


