$:.unshift(File.dirname(__FILE__)) 

require 'date'

%w[fileutils 
  readline
  ].each { |f| require "#{f}" }

  %w[
    base
    item
    connectors/org_mode
    cli_helper].each { |f| require "fire_engine/#{f}" }

    module FireEngine

      class << self
        def register_blog_for_repo(repo_name,blog_name,blog_path)
          repos = load_repo_list
          repo = repos[repo_name]
          return "Repo not found" unless repo 
          blogs = repos['blogs'] = {}
          blogs[blog_name] = blog_path
          save_repo_list(repos)
        end

        def available_repos
          repos = load_repo_list
          repos
        end

        def quickblog(tags,repo_name,blog_name)
          #path to journal hardcoded for now
          repos = load_repo_list
          repo_path = repos[repo_name]
          blog_path = repos['blogs'][blog_name]
          data = FireEngine::Connectors::OrgMode.new(File.join(repo_path,'data','blog','journal.org'))
          data.items
          #for now, I the workflow will use a temporary tag called blogit and that's it
          toblog = data.items.children.select { |i| i.tags.include?('blogit') }[0]

          FileUtils.rm(File.join(self.get_fire_path,'to_blog_temp.markdown')) if File.exists?(File.join(self.get_fire_path,'to_blog_temp.markdown'))

          #File.open(File.join(self.get_fire_path,'to_blog_temp.org'),'w') do |file|
            #file.write(toblog.title + "\n" + toblog.body)
          #end

          #need to parameterize the path or include the export-to-markdown script in the firenegine gem
          #for now, hardcoded
          #

          #out = `#{repo_path}/script/export-to-markdown.el`
          title = clean_title(toblog)
          title = title.split(" ").join("-").downcase
          blog_post_filename = "#{Date.today.strftime}-#{title}"

          content = self.remove_left_spaces(self.to_markdown(toblog))

          File.open(File.join(self.get_fire_path,'to_blog_temp.markdown'),'w') { |file| file.write(content) }

          FileUtils.mv(File.join(self.get_fire_path,'to_blog_temp.markdown'),File.join(blog_path,'_posts',blog_post_filename + ".markdown"))

          `cd #{blog_path} && rvm ruby-1.9.3-p194 do jekyll`
        end

        def remove_left_spaces(text)
          text.split("\n").map(&:strip).join("\n") 
        end

        def clean_title(item)
          title = item.title.split(" ")
          title.pop;title.shift
          title.join(" ")
        end

        def to_markdown(item)
          title = clean_title(item)
          text = ""
          #text << title
          #underline = []
          #0.upto(title.length-1) do 
            #underline << "="
          #end
          #text << "\n"
          #text << underline.join
          #text << "\n"
          text << item.body
          text
        end


        def init(repo_name)
          #TODO Encapsulate this to an orgrepo class
          repos = load_repo_list
          repos = {} unless repos
          current_dir = Dir.pwd
          if repos.has_value?(current_dir) || repos.has_value?(repo_name)
            "Cannot use same name or existing dir!"
          else
            repos[repo_name] = current_dir
            save_repo_list(repos)
            "Repository #{current_dir} registered"
          end

        end

        def save_repo_list(repos)
          create_repo_dir_if_non_existent
          File.open(File.join(self.get_repos_path),'w+') do |file|
              file.write(repos.to_yaml)
          end
        end
        
        def get_home
          File.expand_path('~')
        end

        def create_repo_dir_if_non_existent
          unless Dir.exists?(self.get_fire_path)
            Dir.mkdir(self.get_fire_path)
          end
        end
        def load_repo_list
          create_repo_dir_if_non_existent
          repos = YAML.load_file(self.get_repos_path) rescue {}
          repos
        end

        def get_repos_path
          File.join(self.get_fire_path,'repos.yml')
        end

        def get_fire_path
          File.join(self.get_home,'.fire')
        end

        def cli_helper
          CLIHelper
        end
      end
    end
    



