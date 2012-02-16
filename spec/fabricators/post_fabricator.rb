Fabricator(:post) do
  user     { Fabricate(:user) }
  title    { Faker::Lorem.sentence }
  markdown { Faker::Lorem.paragraphs }
end