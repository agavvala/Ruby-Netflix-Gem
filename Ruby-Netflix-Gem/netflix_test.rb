require_relative "netflix"
require "test/unit"

# individual test cases for each netflix api
class NetflixTest < MiniTest::Unit::TestCase

  def setup
    @netflix = Netflix::API.new("xyz", "abc")
  end

  def test_search_people
    http_response = @netflix.search_people('joan')
    puts "Response:"+http_response.code
    puts http_response.body

    assert !http_response.nil?
  end

  def test_get_person_by_id
    http_response = @netflix.get_person_by_id(152672)
    puts "Response:"+http_response.code
    puts http_response.body

    assert !http_response.nil?

  end
end