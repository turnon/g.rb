class Line

  attr_reader :content, :no
  attr_writer :match

  def initialize(content, no)
    @content = content
    @no = no
  end

  def match(keys, *not_keys)
    ms = keys.map{|k| @content.match k}
    return if ms.any?{|m| m.nil?}
    return if not not_keys.empty? and not_keys.first.any?{|k| @content.match k}
    positions = ms.map{|m| [m.pre_match.size, m.pre_match.size + m[0].size]}
    @md = MyMatchData.new @content, positions
  end

  def match?
    not @md.nil?
  end
  
  def to_str
    return (@md.pre_match + highlight(@md[1]) + @md.post_match) if @md
    @content
  end
  
  private

    def highlight(str)
      "\e[44m#{str}\e[0m"
    end
end