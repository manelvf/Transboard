# frozen_string_literal: true

require_relative 'test_helper'

class UploadModuleTest < TransboardTestBase
  include Upload

  def test_getmsgid_with_valid_input
    line = 'msgid "Hello World"' + "\n"
    result = Upload.getMsgid(line)
    assert_equal 'Hello World', result
  end

  def test_getmsgid_with_empty_string
    line = 'msgid ""' + "\n"
    result = Upload.getMsgid(line)
    assert_equal '', result
  end

  def test_getmsgid_with_special_characters
    line = 'msgid "Hello \"World\""' + "\n"
    result = Upload.getMsgid(line)
    assert_equal 'Hello \"World\"', result
  end

  def test_getmsgid_with_invalid_format
    line = 'Hello World' + "\n"
    result = Upload.getMsgid(line)
    assert_nil result
  end

  def test_getmsgid_without_quotes
    line = 'msgid Hello World' + "\n"
    result = Upload.getMsgid(line)
    assert_nil result
  end

  def test_getmsgstr_with_valid_input
    line = 'msgstr "Hola Mundo"' + "\n"
    result = Upload.getMsgstr(line)
    assert_equal 'Hola Mundo', result
  end

  def test_getmsgstr_with_empty_string
    line = 'msgstr ""' + "\n"
    result = Upload.getMsgstr(line)
    assert_equal '', result
  end

  def test_getmsgstr_with_special_characters
    line = 'msgstr "Hola \"Mundo\""' + "\n"
    result = Upload.getMsgstr(line)
    assert_equal 'Hola \"Mundo\"', result
  end

  def test_getmsgstr_with_invalid_format
    line = 'Hola Mundo' + "\n"
    result = Upload.getMsgstr(line)
    assert_nil result
  end

  def test_getmsgstr_without_quotes
    line = 'msgstr Hola Mundo' + "\n"
    result = Upload.getMsgstr(line)
    assert_nil result
  end

  def test_saveupload_with_valid_po_file
    file = mock_po_file(sample_po_content)

    params = {
      'myFile' => { tempfile: file },
      name: 'Test Upload',
      languagefrom: 'English',
      languageto: 'Spanish',
      variation: 'Standard',
      description: 'Test upload',
      visibility: 'public',
      originalFilename: 'test.po'
    }

    result = Upload.saveUpload(params, @test_user.id)

    assert_equal 3, result[:length]
    assert_not_nil result[:docId]
    assert_nil result[:errors]

    # Verify document was created
    doc = Document.find(result[:docId])
    assert_equal 'Test Upload', doc.name
    assert_equal 3, doc.lines.count
    assert_equal 'Hello', doc.lines[0].msgid
    assert_equal 'Hola', doc.lines[0].msgstr

    file.close
    file.unlink
  end

  def test_saveupload_with_empty_file
    file = mock_po_file(empty_po_content)

    params = {
      'myFile' => { tempfile: file },
      name: 'Empty Upload',
      languagefrom: 'English',
      languageto: 'Spanish',
      visibility: 'public',
      originalFilename: 'empty.po'
    }

    result = Upload.saveUpload(params, @test_user.id)

    assert_equal 0, result[:length]
    assert_not_nil result[:docId]

    file.close
    file.unlink
  end

  def test_saveupload_with_multiple_translations
    content = <<~PO
      msgid "One"
      msgstr "Uno"
      msgid "Two"
      msgstr "Dos"
      msgid "Three"
      msgstr "Tres"
      msgid "Four"
      msgstr "Cuatro"
      msgid "Five"
      msgstr "Cinco"
    PO

    file = mock_po_file(content)

    params = {
      'myFile' => { tempfile: file },
      name: 'Multiple Translations',
      languagefrom: 'English',
      languageto: 'Spanish',
      visibility: 'public',
      originalFilename: 'numbers.po'
    }

    result = Upload.saveUpload(params, @test_user.id)

    assert_equal 5, result[:length]
    assert_not_nil result[:docId]

    doc = Document.find(result[:docId])
    assert_equal 5, doc.lines.count
    assert_equal 'One', doc.lines[0].msgid
    assert_equal 'Uno', doc.lines[0].msgstr
    assert_equal 'Five', doc.lines[4].msgid
    assert_equal 'Cinco', doc.lines[4].msgstr

    file.close
    file.unlink
  end

  def test_saveupload_with_incomplete_pairs
    # File with msgid but no msgstr should not count
    content = <<~PO
      msgid "Complete"
      msgstr "Completo"
      msgid "Incomplete"
      # Missing msgstr
      msgid "Another Complete"
      msgstr "Otro Completo"
    PO

    file = mock_po_file(content)

    params = {
      'myFile' => { tempfile: file },
      name: 'Incomplete Pairs',
      languagefrom: 'English',
      languageto: 'Spanish',
      visibility: 'public',
      originalFilename: 'incomplete.po'
    }

    result = Upload.saveUpload(params, @test_user.id)

    # Should only count complete pairs
    assert_equal 2, result[:length]

    file.close
    file.unlink
  end

  def test_saveupload_creates_private_document
    file = mock_po_file(sample_po_content)

    params = {
      'myFile' => { tempfile: file },
      name: 'Private Project',
      languagefrom: 'English',
      languageto: 'Spanish',
      visibility: 'private',
      originalFilename: 'private.po'
    }

    result = Upload.saveUpload(params, @test_user.id)
    doc = Document.find(result[:docId])

    assert_equal true, doc.visibility

    file.close
    file.unlink
  end

  def test_saveupload_creates_public_document
    file = mock_po_file(sample_po_content)

    params = {
      'myFile' => { tempfile: file },
      name: 'Public Project',
      languagefrom: 'English',
      languageto: 'Spanish',
      visibility: 'public',
      originalFilename: 'public.po'
    }

    result = Upload.saveUpload(params, @test_user.id)
    doc = Document.find(result[:docId])

    assert_equal false, doc.visibility

    file.close
    file.unlink
  end
end
