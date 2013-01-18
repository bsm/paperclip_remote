require 'spec_helper'

describe Paperclip::Remote do

  IMAGE_URL = 'http://www.gravatar.com/avatar/file.gif'

  def stub_request!(opts = {})
    opts.reverse_merge! url: IMAGE_URL, body: "GIF89", status: 200

    stub_request(:get, opts[:url]).
      to_return(status: opts[:status], body: opts[:body], headers: {'Content-Type' => 'image/gif'})
  end

  subject { User.new(photo_remote_url: IMAGE_URL) }

  it 'should have remote URL accessor' do
    subject.photo_remote_url.should be_instance_of(URI::HTTP)
    subject.photo_remote_url.to_s.should == IMAGE_URL

    subject.photo_remote_url = "http://example.com"
    subject.photo_remote_url.should be_instance_of(URI::HTTP)
    subject.photo_remote_url.to_s.should == "http://example.com"

    subject.photo_remote_url = ""
    subject.photo_remote_url.should be_nil

    subject.photo_remote_url = "INVALID!!!"
    subject.photo_remote_url.should be_nil

    subject.photo_remote_url = "tcp://some.host/path"
    subject.photo_remote_url.should be_nil
  end

  it 'should assign/overwrite images if remote URL is given' do
    req = stub_request!
    subject.valid?
    subject.photo.should be_file
    subject.photo.original_filename.should == 'file.gif'
    subject.photo.size.should == 5
    subject.photo.content_type.should == 'image/gif'
    req.should have_been_made
  end

  it 'should download/handle large(r) files (when open-uri returns a Tempfile instead of a StringIO)' do
    req = stub_request! body: ("A" * 1_000_000)
    subject.valid?
    subject.photo.should be_file
    subject.photo.size.should == 1_000_000
    subject.photo.original_filename.should == 'file.gif'
    req.should have_been_made
  end

  it 'should ignore invalid inputs' do
    req = stub_request!
    subject.photo_remote_url = 'SOMETHING-INVALID'
    subject.valid?
    subject.photo.should_not be_file
    req.should_not have_been_made
  end

  it 'should ignore invalid URLs' do
    req = stub_request! status: 404
    subject.valid?
    subject.photo.should_not be_file
    req.should have_been_made
  end

end
