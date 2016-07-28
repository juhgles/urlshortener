class CreateShortenedUrls < ActiveRecord::Migration
  def change
    create_table :shortened_urls do |t|
      t.string :shortened_url, null: false, unique: true
      t.string :long_url, null: false
      t.integer :user_id, null: false
      t.timestamps null: false
    end

    add_index :shortened_urls, :shortened_url

  end
end
