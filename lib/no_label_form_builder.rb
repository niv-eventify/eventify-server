require "haml"

module NoLabelFormBuilder
  class Builder < Formtastic::SemanticFormBuilder
    def label(*args)
      ""
    end
  end
end