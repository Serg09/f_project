class Lsi::FixedWidthReader
  @@line_defs = []
  def self.add_line_def(start)
    line = Lsi::LineDefinition.new(start)
    yield line if block_given?
    @@line_defs << line
  end

  attr_accessor :line_count

  def initialize(content)
    @content = content
  end

  def read
    self.line_count = 0
    result = []
    @content.each_line do |line|
      column_defs = get_column_defs(line)
      if column_defs
        data = parse_line(line, column_defs)
        process_data(data)
        yield data if block_given?
        result << data
      else
        Rails.logger.warn "Unable to parse line #{line_count + 1}: #{line}"
      end
      self.line_count += 1
    end
    result
  end

  protected

  def process_data(data)
    # This can be overridden to pre-process or report on the results
  end

  def get_column_defs(line)
    line_def = @@line_defs.lazy.select do |line_def|
      line.starts_with?(line_def.start)
    end.first
    line_def ? line_def.columns : nil
  end

  # Reads a line containing fixed-width columns of data
  def parse_line(line, column_defs)
    result = {}
    start = 0
    column_defs.each do |column_def|
      raw_value = line.slice(start, column_def.length)
      if raw_value.present?
        transformed_value = column_def.transform.call(raw_value.strip)
        result[column_def.name] = transformed_value
      end
      start += column_def.length
    end
    result
  end
end
