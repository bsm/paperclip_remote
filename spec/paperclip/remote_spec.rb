require 'spec_helper'

describe Paperclip::Remote do

  IMAGE_URL = 'http://www.gravatar.com/avatar/file.gif'

  def stub_request!(opts = {})
    opts.reverse_merge! :url => IMAGE_URL, :body => "GIF89", :status => 200

    stub_request(:get, opts[:url]).
      to_return(:status => opts[:status], :body => opts[:body], :headers => {'Content-Type' => 'image/gif'})
  end

  let :record do
    User.new(:photo_remote_url => IMAGE_URL)
  end

  let :subject do
    record.tap(&:valid?)
  end

  it 'should have remote URL accessor' do
    record.photo_remote_url.should == IMAGE_URL
    record.photo_remote_url = "http://example.com"
    record.photo_remote_url.should == "http://example.com"
  end

  it 'should assign/overwrite images if remote URL is given' do
    stub_request!
    subject.photo.should be_file
    subject.photo.original_filename.should == 'file.gif'
    subject.photo.size.should == 5
    subject.photo.content_type.should == 'image/gif'
  end

  it 'should download/handle large(r) files (when open-uri returns a Tempfile instead of a StringIO)' do
    stub_request! :body => ("A" * 1_000_000)
    subject.photo.should be_file
    subject.photo.size.should == 1_000_000
    subject.photo.original_filename.should == 'file.gif'
  end

  it 'should ignore invalid inputs' do
    stub_request!
    record.photo_remote_url = 'SOMETHING-INVALID'
    record.tap(&:valid?).photo.should_not be_file
  end

  it 'should ignore invalid URLs' do
    stub_request! :status => 404
    subject.photo.should_not be_file
  end

end
