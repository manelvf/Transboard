# frozen_string_literal: true

require_relative 'test_helper'

class DocumentModelTest < TransboardTestBase
  def test_document_creation
    doc = create_test_document(@test_user.id)
    assert doc.valid?
    assert_equal 'Test Project', doc.name
    assert_equal 'English', doc.languagefrom
    assert_equal 'Spanish', doc.languageto
    assert_equal @test_user.id.to_s, doc.authorId
  end

  def test_document_requires_name
    doc = Document.new(
      authorId: @test_user.id.to_s,
      languagefrom: 'English',
      languageto: 'Spanish',
      status: 'pending',
      visibility: false
    )
    refute doc.valid?
  end

  def test_document_requires_author_id
    doc = Document.new(
      name: 'Test',
      languagefrom: 'English',
      languageto: 'Spanish',
      status: 'pending',
      visibility: false
    )
    refute doc.valid?
  end

  def test_document_can_have_lines
    doc = create_test_document(@test_user.id)
    line = create_test_line('Hello', 'Hola')
    doc.lines << line
    assert doc.save
    assert_equal 1, doc.lines.count
    assert_equal 'Hello', doc.lines.first.msgid
  end

  def test_document_can_have_collaborations
    doc = create_test_document(@test_user.id)
    collab = create_test_collaboration(@test_user.id, 'accepted')
    doc.collaborations << collab
    assert doc.save
    assert_equal 1, doc.collaborations.count
    assert_equal 'accepted', doc.collaborations.first.status
  end

  def test_document_timestamps
    doc = create_test_document(@test_user.id)
    assert_not_nil doc.created_at
    assert_not_nil doc.updated_at
  end
end

class LineModelTest < TransboardTestBase
  def test_line_creation
    line = create_test_line('Hello', 'Hola')
    assert_equal 'Hello', line.msgid
    assert_equal 'Hola', line.msgstr
  end

  def test_line_can_have_proposals
    doc = create_test_document(@test_user.id)
    line = create_test_line('Hello', 'Hola')
    doc.lines << line
    doc.save

    proposal = create_test_proposal(@test_user.id, 'Alternative translation')
    doc.lines.first.proposals << proposal
    assert doc.save
    assert_equal 1, doc.lines.first.proposals.count
  end

  def test_line_can_have_multiple_proposals
    doc = create_test_document(@test_user.id)
    line = create_test_line('Hello', 'Hola')
    doc.lines << line

    3.times do |i|
      proposal = create_test_proposal(@test_user.id, "Translation #{i}")
      line.proposals << proposal
    end

    assert doc.save
    assert_equal 3, doc.lines.first.proposals.count
  end
end

class ProposalModelTest < TransboardTestBase
  def test_proposal_creation
    proposal = create_test_proposal(@test_user.id, 'Test translation')
    assert_equal 'Test translation', proposal.msgstr
    assert_equal @test_user.id.to_s, proposal.authorId
  end

  def test_proposal_can_have_votes
    doc = create_test_document(@test_user.id)
    line = create_test_line('Hello', 'Hola')
    doc.lines << line

    proposal = create_test_proposal(@test_user.id, 'Translation')
    line.proposals << proposal
    doc.save

    vote = create_test_vote(@test_user.id)
    doc.lines.first.proposals.first.votes << vote
    assert doc.save
    assert_equal 1, doc.lines.first.proposals.first.votes.count
  end

  def test_proposal_timestamps
    doc = create_test_document(@test_user.id)
    line = create_test_line
    proposal = create_test_proposal(@test_user.id)
    line.proposals << proposal
    doc.lines << line
    doc.save

    assert_not_nil doc.lines.first.proposals.first.created_at
    assert_not_nil doc.lines.first.proposals.first.updated_at
  end
end

class VoteModelTest < TransboardTestBase
  def test_vote_creation
    vote = create_test_vote(@test_user.id)
    assert_equal @test_user.id.to_s, vote.authorId
  end

  def test_vote_timestamps
    doc = create_test_document(@test_user.id)
    line = create_test_line
    proposal = create_test_proposal(@test_user.id)
    vote = create_test_vote(@test_user.id)

    proposal.votes << vote
    line.proposals << proposal
    doc.lines << line
    doc.save

    saved_vote = doc.lines.first.proposals.first.votes.first
    assert_not_nil saved_vote.created_at
    assert_not_nil saved_vote.updated_at
  end
end

class CollaborationModelTest < TransboardTestBase
  def test_collaboration_creation
    collab = create_test_collaboration(@test_user.id, 'pending')
    assert_equal @test_user.id.to_s, collab.authorId
    assert_equal 'pending', collab.status
  end

  def test_collaboration_status_options
    assert_includes UserStatusOptions, 'pending'
    assert_includes UserStatusOptions, 'accepted'
    assert_includes UserStatusOptions, 'admin'
    assert_includes UserStatusOptions, 'blocked'
  end

  def test_collaboration_timestamps
    doc = create_test_document(@test_user.id)
    collab = create_test_collaboration(@test_user.id, 'accepted')
    doc.collaborations << collab
    doc.save

    saved_collab = doc.collaborations.first
    assert_not_nil saved_collab.created_at
    assert_not_nil saved_collab.updated_at
  end
end

class ModelModuleTest < TransboardTestBase
  def test_create_document
    params = {
      name: 'New Project',
      languagefrom: 'French',
      languageto: 'German',
      variation: 'Swiss',
      description: 'Test description',
      visibility: 'private',
      originalFilename: 'test.po'
    }

    doc = Model.createDocument(params, @test_user.id)
    assert doc.persisted?
    assert_equal 'New Project', doc.name
    assert_equal 'French', doc.languagefrom
    assert_equal 'German', doc.languageto
    assert_equal true, doc.visibility # 'private' should be converted to true
  end

  def test_create_document_public_visibility
    params = {
      name: 'Public Project',
      languagefrom: 'English',
      languageto: 'Spanish',
      visibility: 'public',
      originalFilename: 'test.po'
    }

    doc = Model.createDocument(params, @test_user.id)
    assert_equal false, doc.visibility # 'public' should be converted to false
  end

  def test_append_line
    doc = create_test_document(@test_user.id)
    Model.appendLine(doc, 'Hello World', 'Hola Mundo')
    doc.save

    assert_equal 1, doc.lines.count
    assert_equal 'Hello World', doc.lines.first.msgid
    assert_equal 'Hola Mundo', doc.lines.first.msgstr
  end

  def test_get_document
    created_doc = create_test_document(@test_user.id)
    retrieved_doc = Model.getDocument(created_doc.id)

    assert_equal created_doc.id, retrieved_doc.id
    assert_equal created_doc.name, retrieved_doc.name
  end

  def test_get_document_list
    create_test_document(@test_user.id, name: 'Project 1')
    create_test_document(@test_user.id, name: 'Project 2')
    create_test_document(@test_user.id, name: 'Project 3')

    docs = Model.getDocumentList
    assert_equal 3, docs.count
  end

  def test_delete_all_documents
    create_test_document(@test_user.id)
    create_test_document(@test_user.id)
    assert_equal 2, Document.count

    Model.deleteAllDocuments
    assert_equal 0, Document.count
  end
end
