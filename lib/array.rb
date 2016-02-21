class Array

  alias_method :old_ref, :[]

  def [](*para)
    p1 = para.old_ref(0)
    return old_ref(*para) unless p1.is_a? Array
    p1.map{|r| old_ref(r) } # p1,p2,p3... should be ranges here
  end

end