Fabricator(:comment) do
  user        { Fabricate(:user) }
  commentable { Fabricate(:post) }
  markdown    { Faker::Lorem.paragraphs }
end
