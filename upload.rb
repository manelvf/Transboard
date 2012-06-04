
module Upload

  def self.saveUpload(params, authorId)

    file = params['myFile']

    n_of_lines = 0
    msgId = nil
    msgStr = nil

    doc = Model::createDocument(params, authorId)

    File.open(file[:tempfile], "r") do |f|

      while (s = f.gets)

        if msgId.nil?
          msgId = getMsgid(s)
        else
          msgStr = getMsgstr(s)
          unless msgId.nil? or msgStr.nil? 
            n_of_lines = n_of_lines + 1
            
            Model::appendLine(doc, msgId, msgStr)

            msgId = nil
            msgStr = nil
          end
        end
      end
    end

    unless doc.save
      return {:errors => doc.errors.map {|k,v| "#{k}: #{v}"}}
    else
      return {:length=>n_of_lines, :docId=>doc.id}
    end

  end

  # 
  # message string functions
  #

  def getMsgid(line) 
    m = /^msgid "(.*)"$/.match line
    if not m.nil? 
      return m[1]
    else
      return nil
    end
  end

  def getMsgstr(line)
    m = /^msgstr "(.*)"$/.match line
    if not m.nil? 
      return m[1]
    else
      return nil
    end
  end

  module_function :getMsgid, :getMsgstr

end
