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
    @match_lines = @all_lines.each do |line|
                     line.match(keys, *not_keys)
                   end.select do |line|
                     line.match?
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