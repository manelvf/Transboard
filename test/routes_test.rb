# frozen_string_literal: true

require_relative 'test_helper'

class RoutesTest < TransboardTestBase
  def setup
    super
    # Create and login user for authenticated routes
    @test_user = create_test_user(email: 'testuser@example.com', password: 'testpass123')

    # Mock login by setting session
    post '/login', { email: 'testuser@example.com', password: 'testpass123' }
  end

  def test_index_route
    get '/'
    assert last_response.ok?
  end

  def test_about_route
    get '/about'
    assert last_response.ok?
  end

  def test_create_new_project_route
    get '/create_new_project'
    # Should redirect to login or show page if authenticated
    assert last_response.status.between?(200, 302)
  end

  def test_upload_file_without_file
    post '/uploadFile', {}
    assert_equal 302, last_response.status # Redirect
  end

  def test_upload_file_with_valid_file
    file = mock_po_file(sample_po_content)

    post '/uploadFile', {
      'myFile' => Rack::Test::UploadedFile.new(file.path, 'text/plain'),
      name: 'Test Upload',
      languagefrom: 'English',
      languageto: 'Spanish',
      variation: 'Standard',
      description: 'Test description',
      visibility: 'public',
      originalFilename: 'test.po'
    }

    assert_equal 302, last_response.status # Redirect after successful upload

    file.close
    file.unlink
  end

  def test_editproject_route
    doc = create_test_document(@test_user.id)
    get "/editproject/#{doc.id}"
    assert last_response.status.between?(200, 302)
  end

  def test_delete_route
    doc = create_test_document(@test_user.id)
    get "/delete/#{doc.id}"
    assert last_response.ok?

    # Verify document status changed to deleted
    updated_doc = Document.find(doc.id)
    assert_equal 'deleted', updated_doc.status
  end

  def test_dashboard_route
    get '/dashboard'
    assert last_response.status.between?(200, 302)
  end

  def test_projects_route
    create_test_document(@test_user.id, visibility: false)
    create_test_document(@test_user.id, visibility: false)

    get '/projects'
    assert last_response.status.between?(200, 302)
  end

  def test_download_route
    doc = create_test_document(@test_user.id)
    line1 = create_test_line('Hello', 'Hola')
    line2 = create_test_line('Goodbye', 'Adiós')
    doc.lines << line1
    doc.lines << line2

    # Add proposals with votes
    proposal1 = create_test_proposal(@test_user.id, 'Hola!')
    proposal1.votes << create_test_vote(@test_user.id)
    line1.proposals << proposal1

    proposal2 = create_test_proposal(@test_user.id, 'Adiós!')
    proposal2.votes << create_test_vote(@test_user.id)
    proposal2.votes << create_test_vote(@test_user.id)
    line2.proposals << proposal2

    doc.save

    get "/download/#{doc.id}"
    assert last_response.ok?
    assert_includes last_response.body, 'msgid "Hello"'
    assert_includes last_response.body, 'msgstr "Hola!"'
    assert_includes last_response.body, 'msgid "Goodbye"'
    assert_includes last_response.body, 'msgstr "Adiós!"'
  end
end

class ProposalVoteRoutesTest < TransboardTestBase
  def setup
    super
    @test_user = create_test_user(email: 'testuser@example.com', password: 'testpass123')
    post '/login', { email: 'testuser@example.com', password: 'testpass123' }

    @doc = create_test_document(@test_user.id)
    @line = create_test_line('Hello', 'Hola')
    @doc.lines << @line
    @doc.save
    @line_id = @doc.lines.first.id
  end

  def test_addline_route
    post '/addline', {
      docId: @doc.id.to_s,
      id: @line_id.to_s,
      text: 'New proposal'
    }

    assert last_response.ok?
    assert_equal 'OK', last_response.body

    # Verify proposal was added
    updated_doc = Document.find(@doc.id)
    assert_equal 1, updated_doc.lines.first.proposals.count
    assert_equal 'New proposal', updated_doc.lines.first.proposals.first.msgstr
  end

  def test_vote_route
    proposal = create_test_proposal(@test_user.id, 'Test proposal')
    @doc.lines.first.proposals << proposal
    @doc.save
    proposal_id = @doc.lines.first.proposals.first.id

    post '/vote', {
      docId: @doc.id.to_s,
      lineId: @line_id.to_s,
      propId: proposal_id.to_s
    }

    assert last_response.ok?
    assert_equal 'OK', last_response.body

    # Verify vote was added
    updated_doc = Document.find(@doc.id)
    assert_equal 1, updated_doc.lines.first.proposals.first.votes.count
  end

  def test_vote_route_prevents_duplicate_votes
    proposal = create_test_proposal(@test_user.id, 'Test proposal')
    @doc.lines.first.proposals << proposal
    @doc.save
    proposal_id = @doc.lines.first.proposals.first.id

    # First vote
    post '/vote', {
      docId: @doc.id.to_s,
      lineId: @line_id.to_s,
      propId: proposal_id.to_s
    }
    assert_equal 'OK', last_response.body

    # Second vote from same user
    post '/vote', {
      docId: @doc.id.to_s,
      lineId: @line_id.to_s,
      propId: proposal_id.to_s
    }
    assert_equal 'VOTED', last_response.body

    # Verify only one vote exists
    updated_doc = Document.find(@doc.id)
    assert_equal 1, updated_doc.lines.first.proposals.first.votes.count
  end
end

class CollaborationRoutesTest < TransboardTestBase
  def setup
    super
    @test_user = create_test_user(email: 'owner@example.com', password: 'testpass123')
    @collaborator = create_test_user(email: 'collaborator@example.com', password: 'testpass123')
    post '/login', { email: 'owner@example.com', password: 'testpass123' }

    @doc = create_test_document(@test_user.id)
  end

  def test_askcollaborate_route
    # Login as collaborator
    post '/logout'
    post '/login', { email: 'collaborator@example.com', password: 'testpass123' }

    get "/askcollaborate/#{@doc.id}"
    assert last_response.ok?
    assert_equal 'OK', last_response.body

    # Verify collaboration was added
    updated_doc = Document.find(@doc.id)
    assert_equal 1, updated_doc.collaborations.count
    assert_equal @collaborator.id.to_s, updated_doc.collaborations.first.authorId
    assert_equal 'pending', updated_doc.collaborations.first.status
  end

  def test_askcollaborate_route_prevents_duplicates
    # Add collaboration first
    @doc.collaborations << create_test_collaboration(@collaborator.id, 'pending')
    @doc.save

    # Login as collaborator
    post '/logout'
    post '/login', { email: 'collaborator@example.com', password: 'testpass123' }

    get "/askcollaborate/#{@doc.id}"
    assert last_response.ok?
    assert_equal 'ERROR', last_response.body
  end

  def test_projectoptions_route
    get "/projectoptions/#{@doc.id}"
    assert last_response.status.between?(200, 302)
  end

  def test_changestatus_route
    collab = create_test_collaboration(@collaborator.id, 'pending')
    @doc.collaborations << collab
    @doc.save

    post '/changestatus', {
      docId: @doc.id.to_s,
      authorId: @collaborator.id.to_s,
      status: 'accepted'
    }

    assert last_response.ok?

    # Verify status was changed
    updated_doc = Document.find(@doc.id)
    assert_equal 'accepted', updated_doc.collaborations.first.status
  end
end
