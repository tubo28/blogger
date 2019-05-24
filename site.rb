class Site
  attr_accessor :title, :description, :baseurl, :articles

  def initialize(attrs = {})
    @title = attrs[:title]
    @description = attrs[:description]
    @baseurl = attrs[:baseurl]
    @articles = attrs[:articles]
  end
end
