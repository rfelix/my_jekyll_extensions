# Code based on http://mikewest.org/2009/11/my-jekyll-fork
# forked from http://github.com/rfelix/my_jekyll_extensions

module Jekyll
 
  class TagIndex < Page
    # Initialize a new TagIndex.
    #   +base+ is the String path to the <source>
    #   +dir+ is the String path between <source> and the file
    #
    # Returns <TagIndex>
    def initialize(site, base, dir, tag)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'tag_index.html')
      self.data['tag'] = tag
      # MODIFIED by http://github.com/danc/ 
      # related tags list ( other tags of any post tagged by 'tag')
      # this code will not be run unless _config.yml declares :
      # related_tags: true
      if @site.config['related_tags']
        related = []
        site.tags[tag].each do |post|
          post.tags.each do |rel| 
            related.push(rel) unless rel == tag || related.include?(rel)
          end
        end      
        self.data['related'] = related unless related.empty?
      end
      # END MODIFIED
      tag_title_prefix = site.config['tag_title_prefix'] || 'Tags: '
      self.data['title'] = "#{tag_title_prefix}#{tag}"      
    end
  end


  class Site
    # Write each tag page
    #
    # Returns nothing
    def write_tag_index(dir, tag)
      index = TagIndex.new(self, self.source, dir, tag)
      index.render(self.layouts, site_payload)
      index.write(self.dest)
    end

    def write_tag_indexes
      if self.layouts.key? 'tag_index'
        self.tags.keys.each do |tag|
          dir = self.config['tag_dir'] || 'tags'
          self.write_tag_index(File.join(dir, tag), tag)
        end
      end
    end  
  end
  
  AOP.after(Site, :write) do |site_instance, result, args|
    site_instance.write_tag_indexes
  end
end

