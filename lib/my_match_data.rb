class MyMatchData

  attr_reader :pre_match, :post_match

  def initialize(str, positions)
    poss = positions.sort{|a, b| a <=> b }
    @pre_end, @match_end = poss.first.first, poss.last.last
    @org = str
    @pre_match = str.slice 0, @pre_end
    @m = str.slice @pre_end, @match_end - @pre_end
    @post_match = str.slice @match_end, str.size
  end

  def position
    [@pre_end, @match_end]
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