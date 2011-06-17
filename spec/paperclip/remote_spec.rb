require 'spec_helper'

describe Paperclip::Remote do

  IMAGE_URL = 'http://www.gravatar.com/avatar/file.gif'

  before do
    stub_request(:get, IMAGE_URL).
      to_return(:status => 200, :body => "GIF89", :headers => {'Content-Type' => 'image/gif'})
  end

  it 'should have remote URL accessor' do
    record = User.new
    record.photo_remote_url.should be_nil
    record.photo_remote_url = IMAGE_URL
    record.photo_remote_url.should == IMAGE_URL
  end

  it 'should assign/overwrite images if remote URL is given' do
    record = User.new
    record.photo_remote_url = IMAGE_URL
    record.tap(&:valid?).photo.should be_file
    record.photo.original_filename.should == 'file.gif'
    record.photo.size.should == 5
    record.photo.content_type.should == 'image/gif'
  end

  it 'should ignore invalid inputs' do
    record = User.new
    record.photo_remote_url = 'SOMETHING-INVALID'
    record.tap(&:valid?).photo.should_not be_file
  end

end
