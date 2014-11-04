# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


1.upto(10).each do |i|
  User.create({
    account_id: i,
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name
  })
end

1.upto(10).each do |i|
  friend_id = 0
  while (friend_id == i || friend_id == 0) do
    friend_id = rand(10)
  end

  follower = User.find(i)
  followed = User.find(friend_id)

  follower.follows(followed)
end