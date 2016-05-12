class LsiBatchWriter
  class << self
    attr_accessor :client_id
  end

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

    write_batch_header(io)
    @batch.orders.each{|o| write_order(io, o)}
  end

  private

  def write_batch_header(io)
    io.print "$$HDR"
    io.print number_of_length(LsiBatchWriter.client_id, 6)
    io.print number_of_length(@batch.id, 10)
    io.print @batch.created_at.strftime('%Y%m%d')
    io.print @batch.created_at.strftime('%H%M%S')
    io.puts ""
  end

  def write_order(io, order)
    write_order_header(io, order)
    write_order_address(io, order)
    order.items.each{|i| write_order_item(io, i)}
  end

  def write_order_header(io, order)
    io.print 'H1'
    io.print number_of_length(order.id, 15)
    io.print order.order_date.strftime('%Y%m%d')
  end

  def write_order_address(io, order)
  end

  def write_order_item(io, item)
  end
end
