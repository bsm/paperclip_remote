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

  def has_attached_file_with_remote(name, options = {})
    has_attached_file_without_remote(name, options)

    if attachment_definitions[name][:remote]
      attr_accessor :"#{name}_remote_url"

      before_validation do |record|
        url = record.send(:"#{name}_remote_url")
        if url.present? && (upload = open(URI.parse(url)) rescue nil)
          upload.original_filename = File.basename(upload.base_uri.path)
          send :"#{name}=", upload
        end
      end
    end
  end

end

module Paperclip::ClassMethods # :nodoc:
  include Paperclip::Remote

  alias_method :has_attached_file_without_remote, :has_attached_file
  alias_method :has_attached_file, :has_attached_file_with_remote
end
