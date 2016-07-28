class Tag < ActiveRecord::Base
  validates :name, uniqueness: true

  has_many :taggings,
  class_name: :Tagging,
  primary_key: :id,
  foreign_key: :tag_id

  has_many :urls,
  through: :taggings,
  source: :url

  def self.find_or_create(name)
    tag = Tag.find_by(name: name)
    if tag
      tag
    else
      Tag.create(name: name)
      Tag.last
    end
  end

  def most_popular_urls(n)
    return [urls.first] if urls.length <= 1
    sorted_urls = urls.sort { |a, b| a.num_clicks <=> b.num_clicks }
    sorted_urls[-n..-1]
  end

end
