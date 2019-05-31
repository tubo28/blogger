require 'ostruct'

class Renderer
  @@templates = OpenStruct.new
  @@templates.header  = Tilt.new('./templates/header.slim')
  @@templates.article = Tilt.new('./templates/article.slim')
  @@templates.footer  = Tilt.new('./templates/footer.slim')
  @@templates.page    = Tilt.new('./templates/page.slim')

  def self.render(rootdir, site, articles)
    articles.each do |article|
      puts "rendering '#{article.title}' (#{article.abs_output_path(rootdir)})"
      open(article.outfilepath, 'w') do |io|
        header  = @@templates.header.render(nil, site: site, article: article)
        content = @@templates.article.render(nil, site: site, article: article)
        footer  = @@templates.footer.render(nil, site: site, article: article)
        page    = @@templates.page.render(
          nil, title: "this is title", author: "this is author", description: "this is desc", keywords: "aaa,bbb,ccc",
          header: header, content: content, footer: footer
        )
        io.puts page
      end
    end
    puts 'done!'
  end
end
