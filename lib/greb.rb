# helper

require 'my_match_data'
require 'string'
require 'line'

line_no_formater = lambda do |line|
                     return nil if line.nil?
                     (line.no + 1).to_s.pad(4) + ": " + (line.nil? ? '' :line)
                   end

# variable for pattern

file_pattern = nil
keys = []
not_keys = []
around = nil

# parse options and arguments

require 'optparse'

OptionParser.new do |opts|

  opts.on "-f pattern" do |p|
    file_pattern = Regexp.new(p)
  end

  opts.on "-F pattern" do |p|
    file_pattern = Regexp.new(p, true)
  end

  opts.on "-i re" do |r|
    keys << Regexp.new(r, true)
  end

  opts.on "-n re" do |r|
    not_keys << Regexp.new(r)
  end

  opts.on "-N re" do |r|
    not_keys << Regexp.new(r, true)
  end

  opts.on "-a around" do |a|
    around = a.to_i
  end

end.parse!

keys.concat ARGV.map{|arg| Regexp.new arg}

# find files

files = Dir.glob("**/*").select!{|path| File.file? path}

files.select!{|path| File.basename(path).match file_pattern} if file_pattern

# match

rs = files.map do |path|

       all_lines = File.readlines(path).each_with_index.map do |line, line_no|
                     l = Line.new(line, line_no)
                     l.match(keys, not_keys)
                     l
                   end

       match_lines = all_lines.select{|line| line.match?}

       if around
         match_lines.map! do |line|
           match_line_with_arounds = all_lines[(line.no < around ? 0 : line.no - around)..(line.no - 1)] +
                                     [line] +
                                     all_lines[(line.no + 1)..(line.no + around)] +
                                     [nil] # this nil is to add blank line between every match
           match_line_with_arounds.map! &line_no_formater
         end
       else
         match_lines.map! &line_no_formater
       end

       [(path + ' :').cyan, match_lines, nil] # this nil is to add blank line between every file

     end.select do |_, match|
       not match.empty?
     end

puts rs