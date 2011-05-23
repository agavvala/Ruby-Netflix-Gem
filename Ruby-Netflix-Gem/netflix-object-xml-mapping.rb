require "xml/mapping"

class Link;
end
class Title;
end
class BoxArt;
end
class Category;
end
class CatalogTitle;
end

class CatalogTitles
  include XML::Mapping

  array_node :links, "link", :class => Link
  text_node :url_template, "url_template", :default_value=>nil
  text_node :number_of_results, "number_of_results", :default_value=>nil
  text_node :start_index, "start_index", :default_value=>nil
  text_node :results_per_page, "results_per_page", :default_value=>nil

  array_node :catalog_titles, "catalog_title", :class => CatalogTitle
end

class BoxArt
  include XML::Mapping

  text_node :small, "@small"
  text_node :medium, "@medium"
  text_node :large, "@large"
end

class Category
  include XML::Mapping

  text_node :scheme, "@scheme"
  text_node :label, "@label"
  text_node :term, "@term"
end

class Title
  include XML::Mapping

  text_node :short, "@short"
  text_node :regular, "@regular"
end
class CatalogTitle
  include XML::Mapping

  text_node :id, "id"
  object_node :title, "title", :class => Title
  object_node :box_art, "box_art", :class => BoxArt
  object_node :synopsis_link, "link", :class => Link
  text_node :release_year, "release_year"
  text_node :runtime, "runtime"
  text_node :average_rating, "average_rating"
  array_node :categories, "category", :class => Category

  object_node :cast_link, "link[@title='cast']", :class => Link, :default_value => nil
  object_node :directors_link, "link[@title='directors']", :class => Link, :default_value => nil
  object_node :formats_link, "link[@title='formats']", :class => Link, :default_value => nil
  object_node :screen_formats_link, "link[@title='screen formats']", :class => Link, :default_value => nil
  object_node :languages_and_audio_link, "link[@title='languages and audio']", :class => Link, :default_value => nil
  object_node :similars_link, "link[@title='similars']", :class => Link, :default_value => nil
  object_node :web_page_link, "link[@title='web page']", :class => Link, :default_value => nil

end

class Link
  include XML::Mapping

  text_node :href, "@href"
  text_node :rel, "@rel"
  text_node :title, "@title"
end

#  forward declarations
class Person; end

class People
  include XML::Mapping

  text_node :number_of_results, "number_of_results"
  text_node :start_index, "start_index"
  text_node :results_per_page, "results_per_page"
  array_node :persons, "person", :class => Person

end

class Person
  include XML::Mapping

  text_node :id, "id"
  text_node :name, "name"
  text_node :bio, "bio/text()", :default_value => nil
  object_node :filmography_link,  "link[@title='filmography']", :class => Link, :default_value => nil
  object_node :web_link,  "link[@title='webpage']", :class => Link , :default_value => nil
end


