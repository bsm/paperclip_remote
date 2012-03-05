ENV["RAILS_ENV"] = "test"
$:.unshift File.dirname(__FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'bundler/setup'

module Rails

  def self.logger
    nil
  end

  def self.root
    @root ||= Pathname.new(File.dirname(__FILE__))
  end

  def self.env
    @env ||= ActiveSupport::StringInquirer.new(ENV["RAILS_ENV"])
  end

end

Bundler.require :default, :test

require 'webmock/rspec'
WebMock.disable_net_connect!

require 'active_record'
Paperclip::Railtie.insert

require 'paperclip_remote'

ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => ":memory:"
ActiveRecord::Base.connection.create_table :users do |t|
  t.string  :photo_content_type
  t.string  :photo_file_name
  t.integer :photo_file_size
end

class User < ActiveRecord::Base
  has_attached_file :photo, :remote => true
end
