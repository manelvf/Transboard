require 'mongo_mapper'



class Document
  include MongoMapper::Document

  key :name, String, :required => true
  key :language, String, :required => true
  key :variation, String
  key :description, String
  key :authorId, String, :required => true
  key :status, String, :required => true
  key :is_private, Boolean
  key :collaboratorIds, Array

  many :lines
end


class Line
  include MongoMapper::EmbeddedDocument

  key :msgid, String
  key :msgstr, String

  many :proposals
  belongs_to :Document
end

class Proposal
  include MongoMapper::EmbeddedDocument

  key :msgstr, String
  key :authorId, String
  
  many :votes
  belongs_to :Line
end

class Vote
  include MongoMapper::EmbeddedDocument

  key :authorId, String
  key :when, Time

  belongs_to :Proposal
end



module Model

  public

  # Save whole document (upload)
  def self.createDocument(params, authorId)
    return Document.create({
      :authorId=>authorId,
      :name=>params[:name],
      :language=>params[:language],
      :variation=>params[:variation],
      :description=>params[:description],
      :status=>"pending"
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
    puts id
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

