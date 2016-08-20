module ContentHelpers
  def description_to_id(description)
    description.gsub(/\s+/, '-').downcase
  end

  def parse_table(html_table)
    rows = html_table.all('tr')
    rows.map{|row| row.all('td,th').map{|c| c.text.strip}}
  end

  def table_as_maps(table)
    keys = table.raw.first.map{|key| key.gsub(/\s+/, '_').downcase.underscore.to_sym}
    table.raw.drop(1).map do |array|
      Hash[*keys.zip(array).flatten]
    end.each do |attributes|
      yield attributes if block_given?
    end
  end
end
World(ContentHelpers)
