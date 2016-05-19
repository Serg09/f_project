class Lsi::FixedWidthReader
  ColumnDef = Struct.new(:name, :length, :transform)

  @@line_defs = []
  def self.add_line_def(start, column_defs, new_record_marker = false)
    @@line_defs << {
      start: start,
      column_defs: column_defs,
      new_record_marker: new_record_marker
    }
  end

  def initialize(content)
    @content = content
  end

  def read
    current_record = {}
    result = []
    @content.each_line do |line|
      column_defs, new_record = get_column_defs(line)
      if column_defs
        hash = parse_line(line, column_defs)
        if new_record
          unless current_record.empty?
            result << current_record
            yield current_record if block_given?
            current_record = {}
          end
        end
        process_line(current_record, hash)
      end
    end
    unless current_record.empty?
      result << current_record
      yield current_record if block_given?
    end
    result
  end

  protected

  def get_column_defs(line)
    line_def = @@line_defs.lazy.select do |line_def|
      line.starts_with?(line_def[:start])
    end.first
    line_def ? [line_def[:column_defs], line_def[:new_record_marker]] : nil
  end

  def process_line(current_record, data)
    raise 'must implemented process_line(current_record, data)'
  end

  def self.parse_date(string_date)
    Date.new(
      string_date[0..3].to_i,
      string_date[4..5].to_i,
      string_date[6..7].to_i
    )
  end

  # Reads a line containing fixed-width columns of data
  def parse_line(line, column_defs)
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
