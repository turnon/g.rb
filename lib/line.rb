require "rchardet"

class Line

  attr_reader :content, :no
  attr_writer :match

  def initialize(content, no)
    @content = content
    @no = no
  end

  def match(keys, *not_keys)
    @k_m =
      begin
        key_and_match keys
      rescue
        decode
        key_and_match keys
      end
    @k_m.map!{|k, m| [k, nil]} if not not_keys.empty? and not_keys.first.any?{|k| @content.match k}
    @k_m
  end

  def match?
    @k_m.any?{|k, match| match}
  end
  
  def to_str
    if match?
      # get the scope of macth data
      positions = @k_m.select do |k, match|
                    match
                  end.map do |k, m|
                    [m.pre_match.size, m.pre_match.size + m[0].size]
                  end.sort do |a, b|
                    a <=> b
                  end
      pre_end, match_end = positions.first.first, positions.last.last

      # extract substring and highlight it
      pre_match = @content.slice 0, pre_end
      m = @content.slice pre_end, match_end - pre_end
      post_match = @content.slice match_end, @content.size
      pre_match + highlight(m) + post_match
    else
      @content
    end
  end
  
  private

    def highlight(str)
      "\e[44m#{str}\e[0m"
    end

    def decode
      @content.force_encoding CharDet.detect(@content)['encoding']
    end

    def key_and_match(keys)
      keys.map{|k| [k, @content.match(k) ] }
    end

end