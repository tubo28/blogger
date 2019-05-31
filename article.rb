require 'pathname'

class Article
  attr_accessor :title, :time, :author, :tags, :description,
                :abs_input_path, :rel_input_path

  def self.from_file(abs_input_path)
    abs_input_path = Pathname.new(abs_input_path)
    raise unless abs_input_path.absolute?

    meta = MarkdownLoader.load_meta(abs_input_path)

    Article.new(
      title: meta['title'],
      time: meta['time'],
      author: meta['author'],
      description: 'hoge',
      tags: meta['tags'],
      abs_input_path: abs_input_path,
    )
  end

  def abs_output_path(base)
    p base
    p @rel_input_path
    (base + @rel_input_path).sub_ext('html').to_s
  end

  def render_content
    str = Kramdown::Document.new(
      MarkdownLoader.load_body(@abs_input_path),
      input: 'MyKramdown'
    ).to_html

    open(abs_output_path, 'w') do |f|
      f.puts str
    end
  end

  private

  def initialize(attrs = {})
    @title = attrs[:title]
    @time = attrs[:time]
    @author = attrs[:author]
    @description = attrs[:description]
    @tags = attrs[:tags]
    @abs_input_path = attrs[:abs_input_path]
  end
end
