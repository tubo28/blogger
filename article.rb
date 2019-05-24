require 'pathname'

class Article
  attr_accessor :title, :date, :author, :tags, :filepath

  def initialize(attrs = {})
    @title = attrs[:title]
    @date = attrs[:date]
    @author = attrs[:author]
    @tags = attrs[:tags]
    @filepath = attrs[:filepath]
  end

  def self.from_file(filepath)
    raise unless Pathname.new(filepath).absolute?

    article = Article.new

    article.filepath = filepath
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

  private

  def outfilepath
    Pathname.new(@filepath).sub_ext('.html').to_s
  end
end
