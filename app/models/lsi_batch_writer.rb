class LsiBatchWriter
  def initialize(batch)
    @batch = batch
  end

  # Right-pads the value up to the specified
  # length with blank spaces, or truncates the
  # values to the specified length if the
  # values is longer
  def alpha_of_length(value, length)
    return value if value.length == length
    if value.length < length
      "#{value}#{" " * (length - value.length)}"
    else
      value.slice(0, length)
    end
  end

  def client_id
    # TODO Read from some configuration
    3
  end

  # Left-pads the value up to the specified
  # length with zeros. Raises an exception
  # if the value is longer than the specified
  # length
  def number_of_length(value, length)
    result = value.to_s
    if result.length > length
      raise ArgumentError.new "The value #{value} is longer than the specified length #{length}"
    end

    "#{"0" * (length - result.length)}#{result}"
  end

  def write(io)
    raise 'Batch has no orders' unless @batch.orders.any?

    io.puts "$$HDR#{@lient_id}"
  end
end
