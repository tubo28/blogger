require 'optparse'
require 'pathname'
require_relative './markdown_loader'

# TODO: Filepath使う
# TODO: ヘッダとかフッタとか
# TODO: テスト

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

  def outfilepath
    Pathname.new(@filepath).sub_ext('.html').to_s
  end
  
  def render_to(io)
    # alt: Kramdown::Document.new(File.open(md).read, input: 'GFM').to_html
    # open(filepath, 'w')
    io.print(
      Kramdown::Document.new(
        MarkdownLoader.load_body(filepath),
        input: 'MyKramdown'
      ).to_html
    )
  end
end

args = {}

optparser = OptionParser.new do |opt|
  opt.on('-i DIR', '--in', '記事があるディレクトリ', String) do |arg|
    args[:in] = arg
  end
  # TODO
  # opt.on('-o DIR', '--out', 'HTMLが出力されるディレクトリ', String) do |arg|
  #   args[:out] = arg
  # end
end

begin
  optparser.parse!
rescue OptionParser::ParseError => e
  puts e
  exit 1
end

inputdir = File.expand_path(args[:in])
mdfiles = Dir.glob(File.join(inputdir, '*.md'))

articles = mdfiles.map { |md| Article.from_file(md) }
tags = articles.map { |art| art.tags }.flatten.sort.uniq

puts "found tags: #{tags.join(', ')}"

articles.each do |art|
  # p art
  puts "rendering '#{art.title}' (#{art.filepath})"
  open(art.outfilepath, 'w') do |io|
    art.render_to(io)
  end
end

puts 'done!'
