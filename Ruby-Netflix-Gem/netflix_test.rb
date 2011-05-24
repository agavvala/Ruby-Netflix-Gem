require_relative "netflix"
require "test/unit"

# individual test cases for each netflix api
class NetflixTest < MiniTest::Unit::TestCase

  def setup
    @netflix = Netflix::API.new("xyz", "abc")
  end

  def test1_search_people
    http_response = @netflix.search_people('joan')
    #puts "Response:"+http_response.code
    #puts http_response.body

    assert !http_response.nil?
  end

  def test1_get_person_by_id
    http_response = @netflix.get_person_by_id(152672)
    #puts "Response:"+http_response.code
    #puts http_response.body

    assert !http_response.nil?

  end
          1
  def test_search_titles
#    response = @netflix.search_title("annamayya")

#    assert (response.results_per_page "10")
  end

  def test1_marshall_titles
    file = File.dirname($0) + '/title_sample.xml'
    titles = CatalogTitles.load_from_file(file)
    titles
  end

  def test_search_people
    #file = File.dirname($0) + '/people_sample.xml'
    #people = People.load_from_file(file)
    #people
    people = @netflix.search_people("john")
    puts people
  end

end