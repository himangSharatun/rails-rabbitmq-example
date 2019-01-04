# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
start_num = 0
total = 5
username = User.where('username like ? ', 'user%').order(id: :desc).first&.username

start_num = username[/\d+/].to_i if username

puts "Start Creating #{total} User, Starting From ID: #{start_num+1}"

count = 0
(start_num+1..start_num+total).each do |i|
  User.create!(
    username: "user%.d" % i,
    balance: 1_000
  )
  count += 1
  puts "Creating user#{i}: #{count}/#{total}"
end