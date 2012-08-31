module FireEngine
  class Item
    attr_accessor :children,:title,:body,:parent,:tags

    def initialize(attributes = {})
      self.children = []
      self.title = attributes.delete(:title)
      self.body = attributes.delete(:body) || ''
      self.parent = attributes.delete(:parent) || nil
      self.tags = attributes.delete(:tags) || []
    end
  end
end
