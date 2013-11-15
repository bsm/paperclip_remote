require 'paperclip'
require 'open-uri'

# Allows fetching files from remote locations. Example:
#
#   class User < ActiveRecord::Base
#     has_attached_file :photo, :remote => true
#     attr_accessible   :photo, :photo_remote_url
#   end
#
# In the form you can then have:
#
#    <%= f.label :photo, "Please update a photo" %>
#    <%= f.file_field :photo %>
#    <br/>
#    <%= f.label :photo_remote_url, "or specify a URL" %>
#    <%= f.text_field :photo_remote_url %>
#
module Paperclip::Remote
  def self.included(base)
    locale_path = Dir.glob(File.dirname(__FILE__) + "/locales/*.{rb,yml}")
    I18n.load_path += locale_path unless I18n.load_path.include?(locale_path)
  end

  def has_attached_file_with_remote(name, options = {})
    original = has_attached_file_without_remote(name, options)
    return original unless attachment_definitions[name][:remote]

    attr_reader   :"#{name}_remote_url"
    define_method :"#{name}_remote_url=" do |string|
      url = URI(string.presence) rescue nil
      url = nil unless URI::HTTP === url
      instance_variable_set(:"@#{name}_remote_url", url)
    end

    before_validation do |record|
      url = record.send(:"#{name}_remote_url")
      break unless url.present?

      begin
        if Paperclip::VERSION < "3.1.4"
          io = open(url.to_s)
          def io.original_filename
            File.basename(base_uri.path)
          end
          send :"#{name}=", io
        else
          record.send(:"#{name}_remote_url=", nil) # Reset!
          send :"#{name}=", url
        end
      rescue OpenURI::HTTPError
        record.errors.add(:"#{name}_remote_url", :unreachable)
      end
    end

    original
  end

end

module Paperclip::ClassMethods # :nodoc:
  include Paperclip::Remote

  alias_method :has_attached_file_without_remote, :has_attached_file
  alias_method :has_attached_file, :has_attached_file_with_remote
end
