Factory.define :user do |user|
  user.name                  "Misha"
  user.email                 "misha@kuz.us"
  user.password              "foobar"
  user.password_confirmation "foobar"
end

Factory.sequence :email do |n|
  "person#{n}@fish.com"
end

Factory.define :micropost do |micropost|
  micropost.content "Foo bar"
  micropost.association :user
end