# helper

require 'line'
require 'match_file'
require 'style'

# variable for pattern

file_pattern = nil
keys = []
not_keys = []
around = nil
in_file = false
output = Style::All

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
    output = Style::Context[a.to_i]
  end

  opts.on "--in-file" do
    in_file = true
  end

  opts.on "--path" do
    output = Style::Path
  end

end.parse!

keys.concat ARGV.map{|arg| Regexp.new arg}

# find files

files = Dir.glob("**/*").select{|path| File.file? path}

files.select!{|path| File.basename(path).match file_pattern} if file_pattern

# match

rs = files.map do |path|
       f = MatchFile.new path
       if in_file
         f.match_all_in_file keys, not_keys
       else
         f.match keys, not_keys
       end
       f
     end.select do |file|
       file.match?
     end.map &output

puts rs
