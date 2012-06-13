require 'mongo_mapper'


class Document
  include MongoMapper::Document

  key :name, String, :required => true
  key :languagefrom, String, :required => true
  key :languageto, String, :required => true
  key :variation, String
  key :description, String
  key :authorId, String, :required => true
  key :status, String, :required => true
  key :visibility, String, :required => true
  key :originalFilename, String

  many :collaborations
  many :lines

  timestamps!
end


class Line
  include MongoMapper::EmbeddedDocument

  key :msgid, String
  key :msgstr, String

  many :proposals
  embedded_in :Document
end

class Proposal
  include MongoMapper::EmbeddedDocument

  key :msgstr, String
  key :authorId, String
  
  many :votes
  embedded_in :Line

  timestamps!
end

class Vote
  include MongoMapper::EmbeddedDocument

  key :authorId, String

  embedded_in :Proposal

  timestamps!
end


class Collaboration
  include MongoMapper::EmbeddedDocument

  key :authorId, String
  key :status, String

  embedded_in :Document

  timestamps!
end



module Model

  public

  # Save whole document (upload)
  def self.createDocument(params, authorId)
    if params[:visibility] == "private"
      visibility = true
    else
      visibility = false
    end

    return Document.create({
      :authorId=>authorId,
      :name=>params[:name],
      :languagefrom=>params[:languagefrom],
      :languageto=>params[:languageto],
      :variation=>params[:variation],
      :description=>params[:description],
      :visibility=>visibility,
      :status=>"pending",
      :originalFilename=>params[:originalFilename]
    })
  end

  def self.appendLine(doc, msgId, msgStr) 
    line = Line.new(:msgid=>msgId, :msgstr=>msgStr)
    doc.lines << line
  end

  def self.deleteAllDocuments()
    $db.collection("documents").remove
  end

  def self.getDocument(id)
    return Document.find(id)
  end

  def self.getDocumentList()
    Document.all
  end

  def self.appendTranslation(docId,lineId,proposedStr,authorId)

  end

  def self.voteTranslation(authorId, vote)
  end

end

