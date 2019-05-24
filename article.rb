require 'pathname'

class Article
  attr_accessor :title, :time, :author, :tags, :filepath, :description

  def self.from_file(filepath)
    filepath = Pathname.new(filepath)
    raise unless filepath.absolute?

    meta = MarkdownLoader.load_meta(filepath)

    Article.new(
      title: meta['title'],
      time: meta['time'],
      author: meta['author'],
      description: 'hoge',
      tags: meta['tags'],
      filepath: filepath,
    )
  end

  def outfilepath
    @filepath.sub_ext('.html').to_s
  end

  def render_content
    Kramdown::Document.new(
      MarkdownLoader.load_body(filepath),
      input: 'MyKramdown'
    ).to_html
  end

  private

  def initialize(attrs = {})
    @title = attrs[:title]
    @time = attrs[:time]
    @author = attrs[:author]
    @description = attrs[:description]
    @tags = attrs[:tags]
    @filepath = attrs[:filepath]
  end
end
