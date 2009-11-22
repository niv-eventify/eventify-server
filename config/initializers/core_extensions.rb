class Array
  def compact_blanks
    self.select {|v| !v.blank?}
  end
end
