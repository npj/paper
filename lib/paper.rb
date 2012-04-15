module Paper
  
  def self.random_string(length, chars = nil)
    raise "length must be greater than 0" unless length > 0
    chars ||= (?0..?9).to_a + (?a..?z).to_a + (?A..?Z).to_a
    length.times.inject("") { |str,_| str << chars[rand(chars.length)] }
  end
  
  def self.url_helpers
     Paper::Application.routes.url_helpers
  end
end