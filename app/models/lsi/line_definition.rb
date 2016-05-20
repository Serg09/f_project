class Lsi::LineDefinition
  TRANSFORMERS = {
    integer:   ->(v){v.to_i},
    date:      ->(v){parse_date(v)},
    decimal:   ->(v){BigDecimal.new(v) / 100},
    date_time: ->(v){parse_date_time(v)}
  }

  attr_accessor :start

  def initialize(start)
    self.start = start
  end

  def column(name, length, transform = nil)
    columns << Lsi::ColumnDefinition.new(name, length, resolve_transform(transform))
  end

  def columns
    @columns ||= []
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

  def resolve_transform(transform)
    if transform.is_a? Symbol
      TRANSFORMERS[transform] || raise("Unrecognized transform key #{transform}")
    else
      transform || ->(v){v}
    end
  end
end
