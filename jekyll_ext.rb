Dir[File.join(File.dirname(__FILE__), "*.rb")].each do |f| 
  unless f =~ /jekyll\_ext\.rb$/
    puts "Loading Extension: #{File.basename(f)}"
    load f
  end
end