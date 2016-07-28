class ShortenedUrlsController < ApplicationController

  def index
    @urls = ShortenedUrl.all
  end

  def new
    @url = ShortenedUrl.new
  end

  def create
    url_params = params[:shortened_url]
    user = User.find_by_id(url_params[:user_id])
    ShortenedUrl.create_for_user_and_long_url!(user, url_params[:long_url])
    redirect_to root_path
  end

  def link
    url = ShortenedUrl.find_by_short_url(params[:id])
    Visit.record_visit!(User.new(id: 1), url)
    redirect_to "http://" + url.long_url
  end

end
