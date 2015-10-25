def fuzzy_hash_search(hash, name, item_name)
	all_keys = hash.keys
	expression = name.gsub(/@({([^:]+|)})/){ |match| print match }
	keys = all_keys.grep(/^#{expression}$/)

	if keys.empty? or keys.grep(/^#{expression}$/).size < 1

		message = sprintf('%s "%s" is not defined.', item_name.capitalize, name);

		if (alternatives = find_alternatives(name, all_keys)).length > 0
			if alternatives.length == 1
				message += "\n\nDid you mean this?\n"
			else
				message += "\n\nDid you mean one of these?\n"
			end
			alternatives.keys.each do |alternative|
				message += "\t" + alternative.to_s + "\n"
			end
		end
		raise HashNotFoundException.new(message, alternatives)
	end


	return true
end

def find_alternatives(name, collection)
	alternatives = {}

	name_downcase = name.downcase
	collection.each do |item|
		item_downcase = item.downcase
		lev = levenshtein_distance(name_downcase, item_downcase)
		if lev <= name_downcase.length / 3 or item_downcase.index(name_downcase) != nil
			alternatives[item] = alternatives.key?(:item) ? (alternatives[item] - lev) : (lev)
		end
	end

	return alternatives
end

def levenshtein_distance(s, t)
  m = s.length
  n = t.length
  return m if n == 0
  return n if m == 0
  d = Array.new(m+1) {Array.new(n+1)}

  (0..m).each {|i| d[i][0] = i}
  (0..n).each {|j| d[0][j] = j}
  (1..n).each do |j|
    (1..m).each do |i|
      d[i][j] = if s[i-1] == t[j-1]  # adjust index into string
                  d[i-1][j-1]       # no operation required
                else
                  [ d[i-1][j]+1,    # deletion
                    d[i][j-1]+1,    # insertion
                    d[i-1][j-1]+1,  # substitution
                  ].min
                end
    end
  end
  d[m][n]
end

class HashNotFoundException < Exception

	def initialize(message, alternatives)
        @message = message
        @alternatives = alternatives
    end
    def message
    	@message
    end
    def alternatives
    	@alternatives
    end
end