require 'string'
require 'array'

module Style

  NL = "\n"

  # file name
  Name = ->(file) {(file.path + ' :').cyan}

  # always with line number
  Line = ->(line) {(line.no + 1).to_s.pad(4) + ": " + (line.nil? ? '' :line)}

  # add newline for each line, since chomped
  Lines = ->(lines) { (lines.map &Line).join NL }

  # have blank lines between lines sets
  LinesSet = ->(ls) { (ls.map &Lines).join(NL * 2) }

  # show macth lines and context
  Context = ->(around) {
               ->(file) {
                  merged_line_range =
                    file.match_lines.map do |line|
                      (line.no < around ? 0 : line.no - around)..(line.no + around)
                    end.reduce([]) do |result, this|
                      # the ranges are sorted and their size are all same
                      prev = result.last
                      if prev.nil? or not prev.cover? this.begin
                        result << this
                      else
                        result.pop
                        result << (prev.begin .. this.end)
                      end
                      result
                    end

                  lines_set = file.all_lines[merged_line_range]

                  Name[file] + NL + LinesSet[lines_set] + NL + NL
               }
            }

  # show macth lines
  All = ->(file) { Name[file] + NL + Lines[file.match_lines] + NL + NL}

  # just show file path
  Path = ->(file) {file.path + NL}

end