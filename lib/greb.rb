#!/bin/env ruby

# helper

class MyMatchData

  attr_reader :pre_match, :post_match

  def initialize(str, pre_end, match_end)
    @org = str
    @pre_match = str.slice 0, pre_end
    @m = str.slice pre_end, match_end - pre_end
    @post_match = str.slice match_end, str.size
  end

  def [](i)
    case i
    when 0
      @org
    when 1
      @m
    else
      nil
    end
  end
end

class String
  def cyan
    "\e[36m#{self}\e[0m"
  end

  def highlight
    "\e[44m#{self}\e[0m"
  end

  def pad(n)
    "%#{n}s" % self
  end

  alias_method :old_match, :match

  def match(keys, *not_keys)
    if keys.is_a? Array
      ms = keys.map{|k| old_match k}
      return nil if ms.any?{|m| m.nil?}
      return nil if not not_keys.empty? and not_keys.first.any?{|k| old_match k}
      positions = ms.map{|m| [m.pre_match.size, m.pre_match.size + m[0].size]}
                    .sort!{|a, b| a <=> b }

      MyMatchData.new self, positions.first.first, positions.last.last
    else
      old_match keys
    end
  end

  def match_and_highlight(keys, *not_keys)
    md = match(keys, *not_keys)
    return (md.pre_match + md[1].highlight + md.post_match) if md
    return nil
  end
end

line_no_formater = lambda do |no, line|
                     return nil if no.nil?
                     (no + 1).to_s.pad(4) + ": " + (line.nil? ? '' :line)
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

       all_lines_with_no = File.readlines(path).each_with_index.map do |line, line_no|
                             [line_no, line]
                           end

       match_lines = all_lines_with_no.map do |line_no, line|
                       [line_no, line.match_and_highlight(keys, not_keys)]
                     end.select do |line_no, match|
                       not match.nil?
                     end

       if around
         match_lines.map! do |no, line|
           match_line_with_arounds = all_lines_with_no[(no < around ? 0 : no - around)..(no - 1)] +
                                     [[no, line]] +
                                     all_lines_with_no[(no + 1)..(no + around)] +
                                     [[nil, nil]] # this nil is to add blank line between every match
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