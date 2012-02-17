Fabricator(:comment) do
  user     { Fabricate(:user) }
  post     { Fabricate(:post) }
  markdown { Faker::Lorem.paragraphs }
end
