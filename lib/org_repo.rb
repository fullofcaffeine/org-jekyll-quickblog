module FireEngine
  module OrgRepo
    
    attr_accessor :root_path
  
    def initialize(path)
       
    end  
      
    #next-actions file
    def gtd_file
      File.join(self.root_path,'gtd','gtd.org')
    end
    
    def journal_file
      File.join(self.root_path,'data','blog','journal.org')
    end
    
  end
end
    
    
    
    