# Reads purchase order acknowledgment files from LSI
class Lsi::PoaReader
  ColumnDef = Struct.new(:name, :length, :transform)
  ORDER_RECORD = [
    ColumnDef.new(:header,    2, ->(v){v}),
    ColumnDef.new(:batch_id, 10, ->(v){v.to_i}),
    ColumnDef.new(:order_id, 15, ->(v){v.to_i}),
    ColumnDef.new(:order_date, 8, ->(v){parse_date(v)})
  ]
  ERROR_RECORD = [
    ColumnDef.new(:header,    2, ->(v){v}),
    ColumnDef.new(:batch_id, 10, ->(v){v.to_i}),
    ColumnDef.new(:order_id, 15, ->(v){v.to_i}),
    ColumnDef.new(:error,    40, ->(v){v})
  ]
  def initialize(content)
    @content = content
  end

  def read
    current_record = {}
    result = []
    @content.each_line do |line|
      if line.start_with?('$$') # Header
      elsif line.start_with?('H1') # Order
        unless current_record.empty?
          result << current_record
          yield current_record if block_given?
        end
        hash = read_line(line, ORDER_RECORD)
        current_record = hash.keep_if{|k,v| [:order_id, :batch_id, :order_date].include?(k)}
      elsif line.start_with?('H2') # Error
        hash = read_line(line, ERROR_RECORD)
        errors = current_record[:errors] || []
        errors << hash[:error]
        current_record[:errors] = errors
      end
    end
    unless current_record.empty?
      result << current_record
      yield current_record if block_given?
    end
    result
  end

  private

  def self.parse_date(string_date)
    Date.new(
      string_date[0..3].to_i,
      string_date[4..5].to_i,
      string_date[6..7].to_i
    )
  end

  # Reads a line containing fixed-width columns of data
  def read_line(line, column_defs)
    result = {}
    start = 0
    column_defs.each do |column_def|
      raw_value = line.slice(start, column_def.length).strip
      transformed_value = column_def.transform.call(raw_value)
      result[column_def.name] = transformed_value
      start += column_def.length
    end
    result
  end
end
