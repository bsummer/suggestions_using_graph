require 'csv'

namespace :data do
  desc "Add outfits and create post relationships"
  task :outfits => :environment do
    Rake::Task["data:add_outfits"].invoke
    Rake::Task["data:posts"].invoke
  end

  desc "Add Random Outfit Objects to database"
  task :add_outfits => :environment do
    1.upto(20).each do |i|
      Outfit.create({outfit_id: i})
    end
  end

  desc "Add relationship for who posted the outfit"
  task :posts => :environment do
    1.upto(20).each do |i|
      r = rand(9) + 1
      outfit = Outfit.find(i)
      user = User.find(r)

      user.posts outfit
    end
  end

  desc "Add relationship for who loves the outfit"
  task :loves => :environment do
    1.upto(20).each do |i|
      r = rand(9) + 1
      outfit = Outfit.find(i)
      user = User.find(r)

      user.loves outfit
    end
  end

  desc "Load following relationships from data/following.csv file"
  task :load_relationships => :environment do
    following = []
    CSV.foreach('data/following.csv') { |row| following << row }
    following.shift
    following.pop

    following.each do |rel|
      followed_id = rel[0].to_i
      follower_id = rel[1].to_i

      follower = User.find_or_create({account_id: follower_id})
      followed = User.find_or_create({account_id: followed_id})

      follower.follows(followed)
    end
  end

  desc "Load following users data from data/users_following.csv file"
  task :load_following => :environment do
    users = []
    CSV.foreach('data/users_following.csv') { |row| users << row }
    users.shift
    users.pop

    users.each do |user|
      account_id = user[0].to_i
      first_name = user[1]
      last_name = user[2]
      User.find_or_create({account_id: account_id, first_name: first_name, last_name: last_name})
    end
  end

  desc "Load followed users data from data/users_followed.csv file"
  task :load_followed => :environment do
    users = []
    CSV.foreach('data/users_followed.csv') { |row| users << row }
    users.shift
    users.pop

    users.each do |user|
      account_id = user[0].to_i
      first_name = user[1]
      last_name = user[2]
      User.find_or_create({account_id: account_id, first_name: first_name, last_name: last_name})
    end
  end

  desc "Load outfits from data/outfits_and_images.csv file"
  task :load_outfits => :environment do
    outfits = []
    CSV.foreach('data/outfits_and_images.csv') { |row| outfits << row }
    outfits.shift
    outfits.pop

    outfits.each do |outfit|
      outfit_id = outfit[0].to_i
      account_id = outfit[1].to_i
      created_at = outfit[2]
      image_url = outfit[5]
      width = outfit[6]
      height = outfit[7]
      outfit = Outfit.find_or_create({outfit_id: outfit_id, created_at: created_at})
    end
  end

  desc "Load images from data/outfits_and_images.csv file"
  task :load_images => :environment do
    outfits = []
    CSV.foreach('data/outfits_and_images.csv') { |row| outfits << row }
    outfits.shift
    outfits.pop

    counter = 0
    outfits.each do |outfit|
      counter += 1

      outfit_id = outfit[0].to_i
      account_id = outfit[1].to_i
      created_at = outfit[2]
      image_id = outfit[5].to_i
      image_url = outfit[6]
      width = outfit[7].to_i
      height = outfit[8].to_i

      image = Image.find_or_create({image_id: image_id, url: image_url, width: width, height: height})
      outfit = Outfit.find_or_create({outfit_id: outfit_id, created_at: created_at})
      outfit.includes(image)

      sleep 2 if (counter % 500 == 0)
    end
  end

  desc "Load posts relationship from data/outfits_and_images.csv file"
  task :load_posts_relationships => :environment do
    outfits = []
    CSV.foreach('data/outfits_and_images.csv') { |row| outfits << row }
    outfits.shift
    outfits.pop

    counter = 0
    outfits.each do |outfit|
      counter += 1

      outfit_id = outfit[0].to_i
      account_id = outfit[1].to_i
      created_at = outfit[2]
      image_id = outfit[5].to_i
      image_url = outfit[6]
      width = outfit[7].to_i
      height = outfit[8].to_i

      user = User.find_or_create({account_id: account_id})
      outfit = Outfit.find_or_create({outfit_id: outfit_id, created_at: created_at})
      user.posts(outfit)

      sleep 2 if (counter % 500 == 0)
    end
  end
end