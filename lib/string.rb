class String
  def cyan
    "\e[36m#{self}\e[0m"
  end

  def pad(n)
    "%#{n}s" % self
  end

end