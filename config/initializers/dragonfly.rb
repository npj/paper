require 'dragonfly'
app = Dragonfly[:images]

app.configure_with(:imagemagick)
app.configure_with(:rails)
app.configure do |c|
  c.datastore = Dragonfly::DataStorage::S3DataStore.new(
    :bucket_name       => Paper.config.s3.bucket,
    :access_key_id     => Paper.config.s3.key,
    :secret_access_key => Paper.config.s3.secret
  )
  
  c.define_url do |app, job, opts|
    if thumb = Thumbnail.where(:job => job.serialize).first
      app.datastore.url_for(thumb.uid)
    else
      app.server.url_for(job)
    end
  end
  
  c.server.before_serve do |job, env|
    Thumbnail.create(:uid => job.store, :job => job.serialize)
  end
end

app.define_macro_on_include(Mongoid::Document, :image_accessor)

Paper::Application.config.middleware.insert 0, 'Rack::Cache', {
  :verbose     => true,
  :metastore   => URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/meta"),
  :entitystore => URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/body")
} unless Rails.env.production?

Paper::Application.config.middleware.insert_after 'Rack::Cache', 'Dragonfly::Middleware', :images