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