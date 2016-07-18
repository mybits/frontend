# coding: utf-8
class PopularResult
  include ActionView::Helpers::NumberHelper
  SCHEME_PATTERN = %r{^https?://}

  attr_accessor :result

  def initialize(search_parameters, result)
    @search_parameters = search_parameters
    @result = result.stringify_keys!
  end

  def ==(other)
    other.respond_to?(:link) && (link == other.link)
  end

  def self.result_accessor(*keys)
    keys.each do |key|
      define_method key do
        result[key.to_s]
      end
    end
  end

  result_accessor :link, :title, :format, :es_score, :public_timestamp

  # External links have a truncated version of their URLs displayed on the
  # results page, but there's little benefit to displaying the URL scheme
  def display_link
    link.sub(SCHEME_PATTERN, '').truncate(48) if link
  end

  def debug_score
    @search_parameters.debug_score
  end

  def to_hash
    {
      debug_score: debug_score,
      link: link,
      examples_present?: result["examples"].present?,
      examples: result["examples"],
      description: result["description"],
      title: result["title"],
      external: format == "recommended-link",
      display_link: display_link,
      attributes: [],
      format: format,
    }
  end
end
