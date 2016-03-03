class MatchFile

  attr_reader :path, :match_lines, :all_lines
  attr_writer :format

  def initialize(path)
    @path = path

    content = File.read path, encoding: 'utf-8'

    @all_lines = content.lines.each_with_index.map do |line, line_no|
                   Line.new(line.chomp, line_no, self)
                 end    
  end

  def match(keys, *not_keys)
    @match_lines = @all_lines.map do |line|
                     [line, line.match(keys, *not_keys)]
                   end.select do |line, key_and_match|
                     key_and_match.all?{|key, match| match}
                   end.map do |line, k_m|
                     line
                   end
  end

  def match_all_in_file(keys, *not_keys)

    key_match_hash = @all_lines.map do |line|
                       Hash[*(line.match(keys, *not_keys)).flatten]
                     end.reduce(Hash[*(keys.map{|k| [k, nil]}.flatten)]) do |result, k_m_hsh|
                       result.merge(k_m_hsh){|k, v1, v2| v1 or v2 }
                     end

    @match_lines = if key_match_hash.all?{|k, m| m}
                     @all_lines.select{|line| line.match?}
                   else
                     []
                   end

  end

  def match?
    not @match_lines.empty?
  end

end