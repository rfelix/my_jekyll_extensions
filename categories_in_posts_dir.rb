module Jekyll  
  
  AOP.before(Post, :content) do |post_instance, args|
    name = post_instance.instance_variable_get(:@name)
    already_done = post_instance.instance_variable_get(:@aop_cat_in_post_done)
    if !already_done && name.include?('/')
      post_instance.categories += name.split('/').reject { |x| x.empty? }
      post_instance.categories.pop # Remove filename
      post_instance.instance_variable_set(:@aop_cat_in_post_done, true)
    end
  end

end