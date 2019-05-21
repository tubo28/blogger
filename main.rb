require 'kramdown'
require 'kramdown-parser-gfm'
require 'optparse'
require 'pathname'
require 'yaml'
require_relative './kramdown_ext'

# TODO: Filepath使う
# TODO: ヘッダとかフッタとか
# TODO: テスト

class Article
  attr_accessor :title, :date, :author, :tags, :filepath

  def initialize(args = {})
    @title = args[:title]
    @date = args[:date]
    @author = args[:author]
    @tags = args[:tags]
    @filepath = args[:filepath]
  end
  
  def self.from_file(filepath)
    raise unless Pathname.new(filepath).absolute?

    article = Article.new

    article.filepath = filepath
    meta = Article.loadmeta(filepath)

    Article.new(
      title: meta['title'],
      date: meta['date'],
      author: meta['author'],
      tags: meta['tags'],
      filepath: filepath
    )
  end

  def self.loadmeta(filepath)
    state = :begin
    meta_lines = []
    File.open(filepath).each do |line|
      case state
      when :begin
        if line.strip == '---'
          state = :meta_info
        end
      when :meta_info
        if line.strip != '---'
          meta_lines << line
        else
          state = :body
          break
        end
      end
    end

    raise unless state == :body

    YAML.load(meta_lines.join("\n"))
  end

  def self.loadmd(filepath)
    state = :begin
    md_lines = []
    File.open(filepath).each do |line|
      case state
      when :begin
        if line.strip == '---'
          state = :meta_info
        end
      when :meta_info
        if line.strip == '---'
          state = :body
        end
      when :body
        md_lines << line
      end
    end

    md_lines.join("\n")
  end

  def outfilepath
    Pathname.new(@filepath).sub_ext('.html').to_s
  end
  
  def render_to(io)
    # alt: Kramdown::Document.new(File.open(md).read, input: 'GFM').to_html
    # open(filepath, 'w')
    io.print(
      Kramdown::Document.new(
        Article.loadmd(filepath),
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
