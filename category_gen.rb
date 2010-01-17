module Jekyll
  
  class CategoryIndex < Page
    # Initialize a new CategoryIndex.
    #   +base+ is the String path to the <source>
    #   +dir+ is the String path between <source> and the file
    #
    # Returns <CategoryIndex>
    def initialize(site, base, dir, category)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'category_index.html')
      self.data['category'] = category
      category_title_prefix = site.config['category_title_prefix'] || 'Category: '
      self.data['title'] = "#{category_title_prefix}#{category}"
    end
  end
  
  class Site
    # Write each category page
    #
    # Returns nothing
    def write_category_index(dir, category)
      index = CategoryIndex.new(self, self.source, dir, category)
      index.render(self.layouts, site_payload)
      index.write(self.dest)
    end

    def write_category_indexes
      if self.layouts.key? 'category_index'
        dir = self.config['category_dir'] || 'categories'
        self.categories.keys.each do |category|
          self.write_category_index(File.join(dir, category), category)
        end
      end
    end
  end
  
  AOP.after(Site, :write) do |site_instance, result, args|
    site_instance.write_category_indexes
  end
end