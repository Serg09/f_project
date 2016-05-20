class Lsi::ColumnDefinition
  attr_accessor :name, :length, :transform

  def initialize(name, length, transform)

    raise 'transform cannot be nil' unless transform

    self.name = name
    self.length = length
    self.transform = transform
  end
end
