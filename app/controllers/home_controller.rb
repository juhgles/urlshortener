class HomeController < ApplicationController

  def index
    @url = ShortenedUrl.new({long_url: "www.amazon.com"})
  end

end
