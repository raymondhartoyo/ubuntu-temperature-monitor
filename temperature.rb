class Temperature
  def initialize(source, value)
    @source = source
    @value = value
  end

  def source
    @source
  end

  def value
    @value
  end

  def to_s
    "#{source}-#{value}"
  end
end
