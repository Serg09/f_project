class Lsi::FixedWidthReader
  class ColumnDef
    TRANSFORMERS = {
      integer:   ->(v){v.to_i},
      date:      ->(v){parse_date(v)},
      date_time: ->(v){parse_date_time(v)}
    }

    attr_accessor :name, :length, :transform

    def initialize(name, length, transform = nil)
      self.name = name
      self.length = length
      if transform.is_a? Symbol
        self.transform = TRANSFORMERS[transform]
      else
        self.transform = transform || ->(v){v}
      end
    end

    private

    def self.parse_date(string_date)
      Date.new(
        string_date[0..3].to_i,
        string_date[4..5].to_i,
        string_date[6..7].to_i
      )
    end

    def self.parse_date_time(string_date_time)
      DateTime.new(
        string_date_time[0..3].to_i,
        string_date_time[4..5].to_i,
        string_date_time[6..7].to_i,
        string_date_time[8..9].to_i,
        string_date_time[10..11].to_i,
        string_date_time[12..13].to_i
      )
    end
  end

  @@line_defs = []
  def self.add_line_def(start, column_defs, new_record_marker = false)
    @@line_defs << {
      start: start,
      column_defs: column_defs,
      new_record_marker: new_record_marker
    }
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
      line.starts_with?(line_def[:start])
    end.first
    line_def ? line_def[:column_defs] : nil
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
