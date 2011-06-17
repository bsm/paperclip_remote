ENV["RAILS_ENV"] = "test"
$:.unshift File.dirname(__FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'bundler'
Bundler.setup

module Rails

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

class User < ActiveRecord::Base
  def self.columns
    @columns ||= [
      ActiveRecord::ConnectionAdapters::Column.new('photo_file_name', nil, 'string'),
      ActiveRecord::ConnectionAdapters::Column.new('photo_file_size', nil, 'int'),
      ActiveRecord::ConnectionAdapters::Column.new('photo_content_type', nil, 'string'),
    ]
  end

  has_attached_file :photo, :remote => true
end
