require 'pathname'

class Article
  attr_accessor :title, :date, :author, :tags, :filepath

  def self.from_file(filepath)
    filepath = Pathname.new(filepath)
    raise unless filepath.absolute?

    meta = MarkdownLoader.load_meta(filepath)

    Article.new(
      title: meta['title'],
      date: meta['date'],
      author: meta['author'],
      tags: meta['tags'],
      filepath: filepath
    )
  end

  def render_to(io)
    # alt: Kramdown::Document.new(File.open(md).read, input: 'GFM').to_html
    io.print(
      Kramdown::Document.new(
        MarkdownLoader.load_body(filepath),
        input: 'MyKramdown'
      ).to_html
    )
  end

  def outfilepath
    @filepath.sub_ext('.html').to_s
  end

  private

  def initialize(attrs = {})
    @title = attrs[:title]
    @date = attrs[:date]
    @author = attrs[:author]
    @tags = attrs[:tags]
    @filepath = attrs[:filepath]
  end
end
