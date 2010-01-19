module Jekyll
  
  module Filters
    
    def shorten(string, word_count)
      words = string.split(' ')
      return string if string.length <= word_count
      
      count = words.length - 1 # number of spaces
      count += 3 # for "..."
      start_i, end_i = 0, words.length - 1
      prefix, suffix = [], []
      while count <= word_count
        [start_i, end_i].each_with_index do |i, pos|
          if words[i].length + count <= word_count
            if pos == 0
              prefix
            else
              suffix
            end << words[i]
            count += words[i].length
          end
        end
        start_i += 1
        end_i -= 1
        break if start_i >= end_i
      end
      "#{prefix.join(' ')}...#{suffix.reverse.join(' ')}"
    end
  end
  
end