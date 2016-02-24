require 'string'

module Style

  Line = ->(line) {(line.no + 1).to_s.pad(4) + ": " + (line.nil? ? '' :line)}

  All = ->(file) {(file.path + ' :').cyan + "\n" + (file.match_lines.map do |line|
                    unless line.is_a? Array
                      Line.call line
                    else
                      (line.map &Line).join + "\n"
                    end
                  end).join + "\n"}

  Path = ->(file) {file.path + "\n"}

end