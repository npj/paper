Fabricator(:user) do
  
  pwd = Paper.random_string(8)
  
  name                  { Faker::Name.name   }
  email                 { Faker::Internet.email }
  password              { pwd }
  password_confirmation { pwd }
  confirmed_at          { Time.now }
end