require 'kramdown'
require 'kramdown/parser/kramdown'
require 'uri'

class Kramdown::Parser::MyKramdown < Kramdown::Parser::Kramdown
  def initialize(source, options)
    super
    @span_parsers.unshift(:my_autolink)
    # @span_parsers.unshift(:ignore_shortcode)
    @span_parsers.unshift(:ignore_latex_math)
  end

  MY_AUTOLINK_START = URI.regexp
  # Parse URL and make it hyperlink.
  def parse_my_autolink
    @src.pos += @src.matched_size
    href = @src.matched
    el = Element.new(:a, nil, 'href' => href)
    add_text(@src[0], el)
    @tree.children << el
  end
  define_parser(:my_autolink, MY_AUTOLINK_START)

  # IGNORE_SHORTCODE = /{{<.*>}}/
  # # Parse {{< shortcode >}} and leave it raw string.
  # def parse_ignore_shortcode
  #   @src.pos += @src.matched_size
  #   @tree.children << Element.new(:raw, @src.matched)
  # end
  # define_parser(:ignore_shortcode, IGNORE_SHORTCODE)

  IGNORE_LATEX_MATH = /(?<!\\)((?<!\$)\${1,2}(?!\$))(.*?)(?<!\\)(?<!\$)\1(?!\$)/
  # Parse $latex math expression$ and leave it raw string.
  def parse_ignore_latex_math
    @src.pos += @src.matched_size
    add_text(@src.matched)
  end
  define_parser(:ignore_latex_math, IGNORE_LATEX_MATH)
end
