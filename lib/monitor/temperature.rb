class Temperature
  SAFE_TEMPERATURE = 80

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

  def unsafe?
    value >= SAFE_TEMPERATURE
  end
end
