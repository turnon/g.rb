require "rchardet"

class MatchFile

  attr_reader :path, :match_lines
  attr_writer :format

  def initialize(path)
    @path = path

    content = File.read path
    content.force_encoding CharDet.detect(content)['encoding']

    @all_lines = content.lines.each_with_index.map do |line, line_no|
                   Line.new(line, line_no)
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

  def context(around)
    merged_line_range = @match_lines.map do |line|
                          (line.no < around ? 0 : line.no - around)..(line.no + around)
                        end.reduce([]) do |result, this| # the ranges are sorted and their size are all same
                          prev = result.last
                          if prev.nil? or not prev.cover? this.begin
                            result << this
                          else
                            result.pop
                            result << (prev.begin .. this.end)
                          end
                          result
                        end

    @match_lines = @all_lines[merged_line_range]
  end

end