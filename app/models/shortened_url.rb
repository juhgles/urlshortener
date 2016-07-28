require_relative 'visit'

class ShortenedUrl < ActiveRecord::Base
  validates :shortened_url, uniqueness: true
  validates :shortened_url, :long_url, :user_id, presence: true
  validates :long_url, length: { maximum: 1024 }
  validate :check_submitted_urls, :premium_user

  belongs_to :submitter,
  class_name: :User,
  primary_key: :id,
  foreign_key: :user_id

  has_many :visits,
  class_name: :Visit,
  primary_key: :id,
  foreign_key: :url_id

  has_many(
    :visitors,
    Proc.new {distinct},
    through: :visits,
    source: :user
  )

  has_many :taggings,
  class_name: :Tagging,
  primary_key: :id,
  foreign_key: :url_id

  has_many :tags,
  through: :taggings,
  source: :tag

  def check_submitted_urls
    fifth_recent = submitter.submitted_urls.limit(5).last
    return unless fifth_recent
    if fifth_recent.created_at > 5.minutes.ago
      self.errors[:count] << "Too many urls recently"
    end
  end

  def premium_user
    return if submitter.premium
    if submitter.submitted_urls.length >= 5
      self.errors[:count] << "Max amount of urls"
    end
  end

  def self.prune
    visits = Visit.where("created_at > ?", 10.minutes.ago).to_a
    urls = visits.map { |visit| visit.url }
    all_urls = ShortenedUrl.all
    prunable_urls = all_urls - urls
    prunable_urls.reject! { |url| url.submitter.premium }
    prunable_urls_ids = prunable_urls.map { |prunable_url| prunable_url.id }
    ShortenedUrl.destroy(prunable_urls_ids)
  end

  def self.random_code
    code = SecureRandom::urlsafe_base64
    if ShortenedUrl.exists?(shortened_url: code)
      self.random_code
    else
      code
    end
  end

  def self.create_for_user_and_long_url!(user, long_url)
    url = ShortenedUrl.new
    url.user_id = user.id
    url.long_url = long_url
    url.shortened_url = self.random_code
    url.save
  end

  def self.find_by_short_url(short_url)
    ShortenedUrl.find_by(shortened_url: short_url)
  end

  def num_clicks
    Visit.where(url_id = @id).count
  end

  def num_uniques
    visitors.count
  end

  def num_recent_uniques
    Visit.where(url_id = @id, created_at > 10.minutes.ago).select(:user_id).distinct.count
  end


end
