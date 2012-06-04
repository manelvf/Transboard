
require File.dirname(__FILE__) + '/transboard.rb'
require File.dirname(__FILE__) + '/upload.rb'
require 'test/unit'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

BASEURL = 'http://localhost:4567'



class TransboardTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include Upload

  def app
    Sinatra::Application
  end

  def setup
    @user = User.all[0]
  end

  # db tests
  def test_db_has_users
    @users = User.all
    assert(@users.length>0)
  end

  def test_use_first_user
    assert (@user.email.length>0)
    assert (@user.class == User)
  end

  def test_login
    post BASEURL + '/login', {:email=>"manelvf@gmail.com", :password=>"apedra"}
    follow_redirect!

    assert last_response.ok?
  end


  def test_upload_form_is_ok
    post BASEURL + '/login', {:email=>"manelvf@gmail.com", :password=>"apedra"}
    follow_redirect!

    get BASEURL + '/create_new_project'
    assert last_response.ok?
    #assert_equal 'Upload new file', last_response.body
    assert last_response.body.include?('Logout')


    # check empty file
    file = File.dirname(__FILE__) + "/fixtures/meneame_empty.po"
    assert File.file?(file)
    # load test file and show 
    post BASEURL + "/uploadFile", {
      "myFile" => Rack::Test::UploadedFile.new(file, "text/plain"),
      :name => "Test File",
      :language => "Armerio"
    }
    follow_redirect!

    assert_not_nil last_request.url.index('/create_new_project')
    #File.open('output.html', 'w') { |f| f.write(last_response.body) }
    assert last_response.ok?
    assert last_response.body.include?('Empty file')


    # now check real file
    file = "fixtures/meneame.po"
    assert File.file?(file)
    # load test file and show 
    post BASEURL + "/uploadFile", {
      "myFile" => Rack::Test::UploadedFile.new(file, "text/plain"),
      :name => "Test File",
      :language => "Armerio"
    }
    File.open('output.html', 'w') { |f| f.write(last_response.body) }
    follow_redirect!
    assert last_response.ok?

    assert last_response.body.include?('4 strings loaded')
  end



  def test_msgid
    #/msgid ""/
    msgid = getMsgid 'msgid "comentario no encontrado"' + "\n"
    s = "comentario no encontrado"
    assert_equal msgid, s

    msgid = getMsgid 'comentario no encontrado' + "\n"
    assert_equal nil, msgid 
  end

  def test_msgstr
    msgstr = getMsgstr 'msgstr "comentario non atopado"' + "\n"
    s = "comentario non atopado"
    assert_equal msgstr, s

    msgstr = getMsgstr 'msgstr comentario non atopado' + "\n"
    assert_equal msgstr, nil 
  end


=begin
  def test_it_says_hello_to_a_person
    get '/', :name => 'Simon'
    assert last_response.body.include?('Simon')
  end
=end
end


