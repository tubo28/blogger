require 'slim'

require 'optparse'
require_relative './markdown_loader'
require_relative './article'
require_relative './site'
require_relative './renderer'

# TODO: テスト

def parse_argv
  args = {}

  optparser = OptionParser.new do |opt|
    opt.on('-i DIR', '--in', '記事があるディレクトリ', String) do |arg|
      args[:in] = arg
    end
    opt.on('-o DIR', '--out', 'HTMLが出力されるディレクトリ', String) do |arg|
      args[:out] = arg
    end
  end

  begin
    optparser.parse!
  rescue OptionParser::ParseError => e
    puts e
    exit 1
  end
  args
end

args = parse_argv

inputdir = File.expand_path(args[:in])
outputdir = File.expand_path(args[:out])

mdfiles = Dir.glob(File.join(inputdir, '*.md'))

articles = mdfiles.map { |md| Article.from_file(md) }

site = Site.new(
  title: 'My Blog',
  baseurl: 'localhost',
  description: 'this is my blog',
  articles: articles
)

# tags = articles.map { |art| art.tags }.flatten.sort.uniq

Renderer.render(outputdir, site, articles)
