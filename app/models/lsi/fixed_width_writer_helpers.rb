module Lsi
  module FixedWidthWriterHelpers

    # Right-pads the value up to the specified
    # length with blank spaces, or truncates the
    # values to the specified length if the
    # values is longer
    def alpha_of_length(value, length)
      result = value.to_s.upcase
      return result if result.length == length
      if result.length < length
        "#{result}#{" " * (length - result.length)}"
      else
        result.slice(0, length)
      end
    end

    # Left-pads the value up to the specified
    # length with zeros. Raises an exception
    # if the value is longer than the specified
    # length
    def number_of_length(value, length, precision = 0)
      result = (value * (10 ** precision)).floor.to_s
      if result.length > length
        raise ArgumentError.new "The value #{value} is longer than the specified length #{length}"
      end

      "#{"0" * (length - result.length)}#{result}"
    end

    def blank_of_length(length)
      ' ' * length
    end
  end
end
