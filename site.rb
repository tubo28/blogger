class Site
  attr_accessor :title, :description, :baseurl

  def initialize(attrs = {})
    @title = attrs[:title]
    @description = attrs[:description]
    @baseurl = attrs[:baseurl]
  end
end
