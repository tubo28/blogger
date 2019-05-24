require 'slim'

require 'optparse'
require_relative './markdown_loader'
require_relative './article'
require_relative './site'

# TODO: テスト

def parse_argv
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
  args
end

site = Site.new(
  title: 'My Blog',
  baseurl: 'localhost',
  description: 'this is my blog'
)

args = parse_argv

inputdir = File.expand_path(args[:in])
mdfiles = Dir.glob(File.join(inputdir, '*.md'))

articles = mdfiles.map { |md| Article.from_file(md) }
tags = articles.map { |art| art.tags }.flatten.sort.uniq

puts "found tags: #{tags.join(', ')}"

header_template  = Tilt.new('./templates/header.slim')
article_template = Tilt.new('./templates/article.slim')
footer_template  = Tilt.new('./templates/footer.slim')
page_temlpate    = Tilt.new('./templates/page.slim')


articles.each do |article|
  puts "rendering '#{article.title}' (#{article.filepath})"
  open(article.outfilepath, 'w') do |io|
    header  = header_template.render(nil, site: site, article: article)
    content = article_template.render(nil, site: site, article: article)
    footer  = footer_template.render(nil, site: site, article: article)
    page    = page_temlpate.render(
      nil, title: "this is title", author: "this is author", description: "this is desc", keywords: "aaa,bbb,ccc",
      header: header, content: content, footer: footer
    )
    io.puts page
  end
end

puts 'done!'
