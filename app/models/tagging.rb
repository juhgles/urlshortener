class Tagging < ActiveRecord::Base

  belongs_to :url,
  class_name: :ShortenedUrl,
  primary_key: :id,
  foreign_key: :url_id

  belongs_to :tag,
  class_name: :Tag,
  primary_key: :id,
  foreign_key: :tag_id



end
