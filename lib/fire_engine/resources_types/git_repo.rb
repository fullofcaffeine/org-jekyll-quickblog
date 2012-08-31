module FireEngine
  module ResourceTypes
    class GitRepo < FireEngine::ResourceType::Base
   
      decorate_connector do |connector|
         connector.after_add :commit
      end
      
      def commit
        
      end
      
      def get_commit_info(SHA1)
      end
      
      #Could we use a git connector later on?
      def list commits
        
      end
   
   
    end
  end
end