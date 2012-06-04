require 'test/unit'
require 'rack/test'
require File.dirname(__FILE__) + '/../transboard.rb'
require File.dirname(__FILE__) + '/../model.rb'
require File.dirname(__FILE__) + '/../upload.rb'

ENV['RACK_ENV'] = 'test' 

require File.dirname(__FILE__) + '/../config_test.rb'

BASEURL = 'http://localhost:4567'


class TransboardTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include Upload
  include Model

  def app
    Sinatra::Application
  end

  def setup

    @user = User.all[0]

  end

  def test_upload_inside
    params = {
      :name => "Test project",
      :language => "Armenian",
      :variation => "Cirillic",
      :description => "This is a serious test"
    }

    Model::deleteAllDocuments()
    assert_equal Model::getDocumentList().length, 0

    test_file = '../fixtures/meneame.po'
    file = Rack::Test::UploadedFile.new(test_file, "text/plain")
    f = {:tempfile => file } # mock
    params['myFile'] = f
    length = Upload::saveUpload(params, 1)
    assert_equal length, 4

    assert_equal Model::getDocumentList().length, 1

  end

end

