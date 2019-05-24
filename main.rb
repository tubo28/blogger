require 'optparse'
require_relative './markdown_loader'
require_relative './article'

# TODO: ヘッダとかフッタとか
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

args = parse_argv

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
