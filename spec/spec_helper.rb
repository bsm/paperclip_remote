ENV["RAILS_ENV"] = "test"
$:.unshift File.dirname(__FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'bundler/setup'
require 'webmock/rspec'
WebMock.disable_net_connect!

require 'rails'
Rails.logger = Logger.new(File.expand_path("../../tmp/test.log", __FILE__))

require 'active_record'
require 'paperclip/remote'
Paperclip::Railtie.insert

ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => ":memory:"
ActiveRecord::Base.connection.create_table :users do |t|
  t.string  :photo_content_type
  t.string  :photo_file_name
  t.integer :photo_file_size
end


class User < ActiveRecord::Base
  has_attached_file :photo, remote: true, path: File.expand_path("../../tmp/:attachment/:id", __FILE__)
end
