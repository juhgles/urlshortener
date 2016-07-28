namespace :clean_up do
  task prune: :environment do
    puts "Purging old URLs"
    ShortenedUrl.prune
  end
end
