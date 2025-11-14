# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/reporters'
require 'rack/test'
require 'simplecov'

# Start SimpleCov for code coverage
SimpleCov.start do
  add_filter '/test/'
  add_filter '/vendor/'
  add_group 'Models', 'model.rb'
  add_group 'Routes', 'transboard.rb'
  add_group 'Modules', ['upload.rb', 'language_codes.rb']
  add_group 'Config', ['config.rb', 'config_test.rb']
end

# Use spec reporter for better test output
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

# Load test configuration first
require File.expand_path('../config_test.rb', __dir__)

# Load application files
require File.expand_path('../model.rb', __dir__)
require File.expand_path('../upload.rb', __dir__)
require File.expand_path('../transboard.rb', __dir__)

# Test helpers module
module TestHelpers
  # Create a test user for authentication
  def create_test_user(email: 'test@example.com', password: 'password123')
    MmUser.create(
      email: email,
      password: password,
      name: email.split('@').first
    )
  rescue StandardError => e
    # User might already exist, try to find it
    MmUser.first(email: email)
  end

  # Clean up test database
  def clean_database
    Document.delete_all
    # Don't delete users as they're needed for authentication
  end

  # Create a test document
  def create_test_document(author_id, overrides = {})
    defaults = {
      name: 'Test Project',
      languagefrom: 'English',
      languageto: 'Spanish',
      variation: 'Standard',
      description: 'Test project description',
      visibility: false,
      status: 'pending',
      originalFilename: 'test.po'
    }

    Document.create(defaults.merge(overrides).merge(authorId: author_id.to_s))
  end

  # Create a test line
  def create_test_line(msgid = 'Hello', msgstr = 'Hola')
    Line.new(msgid: msgid, msgstr: msgstr)
  end

  # Create a test proposal
  def create_test_proposal(author_id, msgstr = 'Translation')
    Proposal.new(msgstr: msgstr, authorId: author_id.to_s)
  end

  # Create a test vote
  def create_test_vote(author_id)
    Vote.new(authorId: author_id.to_s)
  end

  # Create a test collaboration
  def create_test_collaboration(author_id, status = 'pending')
    Collaboration.new(authorId: author_id.to_s, status: status)
  end

  # Mock file upload
  def mock_po_file(content)
    file = Tempfile.new(['test', '.po'])
    file.write(content)
    file.rewind
    file
  end

  # Sample PO file content
  def sample_po_content
    <<~PO
      # Translation file
      msgid "Hello"
      msgstr "Hola"
      msgid "Goodbye"
      msgstr "Adiós"
      msgid "Thank you"
      msgstr "Gracias"
    PO
  end

  # Empty PO file content
  def empty_po_content
    <<~PO
      # Empty translation file
    PO
  end
end

# Base test class
class TransboardTestBase < Minitest::Test
  include Rack::Test::Methods
  include TestHelpers

  def app
    Sinatra::Application
  end

  def setup
    clean_database
    @test_user = create_test_user
  end

  def teardown
    clean_database
  end
end
