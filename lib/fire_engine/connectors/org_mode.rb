require 'digest/md5'
require 'pathname'

Item = FireEngine::Item


module FireEngine
  module Connectors
    class OrgMode 
      
    
      
      attr_accessor :items
      #TODO Add last? first? methods
      #TODO Bug, should not idex based on the string of the title, should generate a random UID instead
      #TODO How to handle syntax that is not orgmode? Check how org-ruby does that, if it does.
      # => By this I mean text that is not within org's boundaries (before org)
      #TODO title SHOULD NOT include tags (they are a spearate piece of information)
      #TODO PROPERTIES drawer parsing

     def initialize(path)
       @filename = Pathname.new(path).basename
       parser = ::Orgmode::Parser.new(File.open(path).read)
       @children = {}
       @headlines = []
       @last_parent = {}
       @root = Item.new(:title => @filename)
       @items = {}
       @parents = {}
       self.parse(parser,0)
       self.to_items
       self.items = @root
     end

      #TODO Improve function. Avoid using global vars after it works. Specialize and
      #simplify. (it's a prototoype so no pressure to have great code for now... just explore
      #until it works the way I want, then improve.
      def parse(parser,i=0,previous_level=0,parent=nil)
        if i < parser.headlines.count
          hl  = parser.headlines[i]
          #str = hl.to_s.gsub('*','').gsub(' ','')
          str = hl.to_s
          level = hl.level
          if (level - previous_level == 1) && previous_level != 0
            parent = parser.headlines[i-1]
            @last_parent[level] = parent
          elsif level == previous_level || level < previous_level
            parent = @last_parent[level]
          else
            parent = nil
          end
          #TODO Fix order
          hl.body_lines.shift #remove title
          @headlines << {:id => Digest::MD5.hexdigest(hl.to_s), :title => str, :body => hl.body_lines.join("\n"), :level => hl.level, :parent => Digest::MD5.hexdigest(parent.to_s), :tags => hl.tags}
          if parent
            unless @children[Digest::MD5.hexdigest(parent.to_s)]
              @children[Digest::MD5.hexdigest(parent.to_s)] = []
            end
            @children[Digest::MD5.hexdigest(parent.to_s)] << {:title => str, :body => hl.body_lines.join("\n"), :parent => Digest::MD5.hexdigest(parent.to_s)}
          end
          parse(parser,i+1,level,parent)
        end
      end
      
      def to_items
        #second pass...
        #converts the simpler data structure to the more abstracted Item datatype adding nesting
        #as well
        @headlines.each do |hl|
          item = (items[hl[:id]] ||= Item.new(:title => hl[:title], :body => hl[:body], :tags => hl[:tags]))
          @root.children << item if hl[:level] == 1
           if items[hl[:parent]]
             item.parent = items[hl[:parent]]
             items[hl[:parent]].children << item
           end
        end
      end

      def item_to_string(item,s="")
        #if item.tags.include?("ruby")
          #puts item.title
          #puts item.body
        #end
        s << "#{item.title}#{item.body == "" ? "" : "\n"}#{item.body}\n" 
        if item.children.count > 0
          item.children.each do |child|
            item_to_string(child,s)
          end
        end
        return s if item.parent.nil?
      end

    end
  end
end
