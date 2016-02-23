# helper

require 'my_match_data'
require 'string'
require 'array'
require 'line'
require 'match_file'

line_no_formater = lambda do |line|
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

files = Dir.glob("**/*").select{|path| File.file? path}

files.select!{|path| File.basename(path).match file_pattern} if file_pattern

# match

rs = files.map do |path|
       f = MatchFile.new path
       f.match keys, not_keys
       f.context around if around
       f
     end.select do |file|
       file.match?
     end.map do |file|
       (file.path + ' :').cyan + "\n" + (file.match_lines.map do |line|
         return line_no_formater.call line unless line.is_a? Array
         (line.map &line_no_formater).join + "\n"
       end).join + "\n"
     end

puts rs
