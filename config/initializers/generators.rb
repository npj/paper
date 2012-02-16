Rails.application.config.generators do |g|
  g.test_framework = :rspec
  g.fixture_replacement :fabrication
end
