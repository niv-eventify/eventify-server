# http://talklikeaduck.denhaven2.com/2009/05/28/safely-dividing-a-utf-8-string-in-ruby

class String
  def utf_snippet(len = 22)
    if len < self.mb_chars.length
      "#{self.mb_chars[0,len]}..."
    else
      self
    end
  end
end
