module BBLib

  def self.hash_path hashes, path, recursive: false, delimiter: '.', symbol_sensitive: false
    if String === path then path = BBLib.split_and_analyze(path, delimiter) end
    if !hashes.is_a? Array then hashes = [hashes] end
    return hashes if path.nil? || path.empty?
    if path[0][:key] == '' then return BBLib.hash_path(hashes, path[1..-1], recursive: true, symbol_sensitive:symbol_sensitive) end
    matches, p = Array.new, path.first
    hashes.each do |hash|
      if recursive
        patterns = Regexp === p[:key] ? p[:key] : p[:key].to_s == '*' ? /.*/ : (symbol_sensitive ? p[:key] : [p[:key].to_sym, p[:key].to_s])
        matches << hash.dig(patterns).flatten[p[:slice]]
        # matches << hash.dig([p[:key].to_sym, p[:key].to_s]).flatten[p[:slice]]
      else
        if Symbol === p[:key] || String === p[:key]
          if p[:key].to_s == '*'
            matches << hash.values.flatten[p[:slice]]
          else
            matches << [symbol_sensitive ? hash[p[:key]] : (hash[p[:key].to_sym] ||= hash[p[:key].to_s])].flatten[p[:slice]]
          end
        elsif Regexp === p[:key]
          hash.keys.find_all{ |k| k =~ p[:key] }.each{ |m| matches << hash[m] }
        end
      end
    end
    matches = BBLib.analyze_hash_path_formula p[:formula], matches
    if path.size > 1 && !matches.empty?
      BBLib.hash_path(matches.flatten.reject{ |r| !r.is_a?(Hash) }, path[1..-1], symbol_sensitive:symbol_sensitive)
    else
      return matches.flatten
    end
  end

  # Will delete this after verifying the refactored version is fully functional
  def self.hash_path_old hashes, path, recursive = false, delimiter: '.'
    return nil if !delimiter
    if delimiter.to_s.size > 1 then delimiter = delimiter[0] end
    if !path.is_a?(Array)
      if path.start_with?(delimiter) then path.sub!(delimiter, '') end
      path = BBLib.split_hash_path path, delimiter
    end
    if !hashes.is_a?(Array) then hashes = [hashes] end
    if path.nil? || path.empty? then return hashes end
    if path.first == '' then return BBLib.hash_path_old(hashes, path[1..-1], true) end
    current = BBLib.hash_path_analyze(path.first)
    possible = []
    hashes.each do |hash|
      if recursive
        possible << hash.dig([current[:key].to_sym, current[:key].to_s]).flatten[current[:slice]]
      else # Not recursive
        if current[:key].is_a?(Symbol) || current[:key].is_a?(String)
          if current[:key].to_s == '*'
            possible << hash.values.flatten[current[:slice]]
          else
            possible << [(hash[current[:key].to_sym] ||= hash[current[:key].to_s])].flatten[current[:slice]]
          end
        else
          hash.keys.map{ |k| k =~ current[:key] }.each do |m|
            if m then possible << hash[m].flatten[current[:slice]] end
          end
        end
      end
    end
    # Analyze formulas if necessary
    if current[:formula]
      temp = []
      possible.flatten.each do |p|
        if current[:formula]
          begin
            if eval(current[:formula].gsub('$', p.to_s))
              temp << p
            end
          rescue StandardError, SyntaxError => se
            # Do nothing, the formula failed and we reject the value as a false
          end
        end
      end
      possible = temp
    end
    # Move on or return the results if no more paths exist
    if path.size > 1 && !possible.empty?
      BBLib.hash_path_old(possible.flatten.reject{ |r| !r.is_a?(Hash) }, path[1..-1])
    else
      return possible.flatten
    end
  end

  def self.hash_path_set hash, *args
    puts args
    return nil unless args && args[0].class == Hash
    map = args[0]
    # puts map
    delimiter = (map[:delimiter] ? map[:delimiter] : '.')
    map.each do |path, value|
      path = BBLib.split_hash_path(path, delimiter)
      last = BBLib.hash_path_analyze path.last
      # puts path, delimiter
      BBLib.hash_path(hash, path[0..-2], delimiter:delimiter ).each do |h|
        p "H - #{h}"
        if Fixnum === last[:slice]
          h[last[:key].to_sym][last[:slice]] = value
        else
          if h.is_a?(Hash)
            h[path.last.to_sym] = value
          end
        end
      end
    end
    hash
  end

  private

    def self.hash_path_analyze path
      key = path.scan(/\A.*^[^\[\(\{]*/i).first.to_s
      if key.encap_by?('/')
        key = eval(key)
      elsif key.start_with? ':'
        key = key[1..-1].to_sym
      end
      slice = eval(path.scan(/(?<=\[).*(?=\])/).first.to_s)
      if slice.nil? then slice = (0..-1) end
      formula = path.scan(/(?<=\().*(?=\))/).first
      {key:key, slice:slice, formula:formula}
    end

    def self.split_hash_path path, delimiter = '.'
      if path.start_with?(delimiter) then path.sub!(delimiter, '') end
      paths, stop, open = [], 0, false
      path.chars.each do |t|
        if t == '[' then open = true end
        if t == ']' then open = false end
        if t == delimiter && !open then paths << path[0..stop].reverse.sub(delimiter,'').reverse; path = path[stop+1..-1]; stop = -1 end
        stop += 1
      end
      paths << path
    end

    def self.split_and_analyze path, delimiter = '.'
      split_hash_path(path, delimiter).collect{ |p| hash_path_analyze(p) }
    end

    def self.analyze_hash_path_formula formula, hashes
      return hashes unless formula
      temp = []
      hashes.flatten.each do |p|
        begin
          if eval(formula.gsub('$', p.to_s))
            temp << p
          end
        rescue StandardError, SyntaxError => se
          # Do nothing, the formula failed and we reject the value as a false
        end
      end
      temp
    end

end



class Hash

  def hash_path path, delimiter: '.'
    BBLib.hash_path self, path, delimiter:delimiter
  end

  # Returns all matching values with a specific key (or Array of keys) recursively within a Hash (included nested Arrays)
  def dig keys, search_arrays: true
    keys = [keys].flatten
    matches = []
    self.each do |k, v|
      if keys.any?{ |a| (a.is_a?(Regexp) ? a =~ k : a == k ) } then matches << v end
      if v.is_a? Hash
        matches+= v.dig(keys)
      elsif v.is_a?(Array) && search_arrays
        v.flatten.each{ |i| if i.is_a?(Hash) then matches+= i.dig(keys) end }
      end
    end
    matches
  end

  # Turns nested values' keys into delimiter separated paths
  def squish delimiter: '.', path_start: nil
    sh = Hash.new
    BBLib.path_nav(self.dup, path_start, delimiter){ |k, v| sh[k] = v }
    sh
  end

  # Expands keys in a hash using a delimiter. Opposite of squish.
  def expand delimiter: '.', symbols: false
    eh = Hash.new
    self.dup.each do |k,v|
      eh.bridge k, delimiter: delimiter, value:v, symbols: true
    end
    return eh
  end

  # Builds out a shell of a hash using a delimited path.
  def bridge path, delimiter: '.', value: nil, symbols: false
    path = (path.is_a?(Array) ? path.join(delimiter) : path.to_s)
    current, paths = self, BBLib.split_and_analyze(path, delimiter)
    if symbols then paths.each{ |p| p[:key] = p[:key].to_s.to_sym } end
    index, count = -1, 0
    paths.each do |p|
      count+=1
      last = paths.size == count
      if p[:slice].is_a?(Fixnum)
        index = p[:slice]
        if current[p[:key]].nil? then current[p[:key]] = [] end
        current = current[p[:key]]
        if last then current.insert index, value end
      else
        if current.is_a?(Hash)
          if last
            current[p[:key]] = value
          else
            current[p[:key]] = current[p[:key]] ||= Hash.new
          end
          current = current[p[:key]]
        else
          if last
            if current[index]
              if current[index].is_a? Hash
                current[index].merge({p[:key] => value})
              else
                current[index] = ({p[:key] => value})
              end
            else
              current.insert index, {p[:key] => value}
            end
          else
            temp = { p[:key] => {} }
            if current[index].is_a? Hash
              current[index].merge!(temp)
            else
              current[index] = temp
            end
          end
          if !last then current = temp[p[:key]] end
        end
        index = -1
      end
    end
    return self
  end

end
