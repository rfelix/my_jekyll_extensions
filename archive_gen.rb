# Code based on http://mikewest.org/2009/11/my-jekyll-fork

module Jekyll
  
  module Filters
    def to_month(input)
      return Date::MONTHNAMES[input.to_i]
    end

    def to_month_abbr(input)
      return Date::ABBR_MONTHNAMES[input.to_i]
    end    
  end

  class Archive < Page
    # Initialize a new Archive.
    #   +base+ is the String path to the <source>
    #   +dir+ is the String path between <source> and the file
    #
    # Returns <Archive>
    def initialize(site, base, dir, type)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)

      self.read_yaml(File.join(base, '_layouts'), type + '.html')

      year, month, day = dir.split('/')
      self.data['year'] = year.to_i
      month and self.data['month'] = month.to_i
      day and self.data['day'] = day.to_i
    end
  end

  
  class Site
    attr_accessor :collated
    
    #   Write post archives to <dest>/<year>/, <dest>/<year>/<month>/,
    #   <dest>/<year>/<month>/<day>/
    #
    #   Returns nothing
    def write_archive( dir, type )
        archive = Archive.new( self, self.source, dir, type )
        archive.render( self.layouts, site_payload )
        archive.write( self.dest )
    end

    def write_archives
        self.collated.keys.each do |y|
            if self.layouts.key? 'archive_yearly'
                self.write_archive( y.to_s, 'archive_yearly' )
            end

            self.collated[ y ].keys.each do |m|
                if self.layouts.key? 'archive_monthly'
                    self.write_archive( "%04d/%02d" % [ y.to_s, m.to_s ], 'archive_monthly' )
                end

                self.collated[ y ][ m ].keys.each do |d|
                    if self.layouts.key? 'archive_daily'
                        self.write_archive( "%04d/%02d/%02d" % [ y.to_s, m.to_s, d.to_s ], 'archive_daily' )
                    end
                end
            end
        end
    end
  end

  AOP.after(Site, :reset) do |site_instance, result, args|
    site_instance.collated = {}
  end
  
  AOP.after(Site, :render) do |site_instance, result, args|
    site_instance.posts.reverse.each do |post|
      y, m, d = post.date.year, post.date.month, post.date.day
      unless site_instance.collated.key? y
        site_instance.collated[ y ] = {}
      end
      unless site_instance.collated[y].key? m
        site_instance.collated[ y ][ m ] = {}
      end
      unless site_instance.collated[ y ][ m ].key? d
        site_instance.collated[ y ][ m ][ d ] = []
      end
      site_instance.collated[ y ][ m ][ d ] += [ post ]
    end
  end
  
  AOP.after(Site, :write) do |site_instance, result, args|
    site_instance.write_archives
  end
  
  AOP.around(Site, :site_payload) do |site_instance, args, proceed, abort|
    result = proceed.call
    result["site"]["collated_posts"] = site_instance.collated
    result
  end
end