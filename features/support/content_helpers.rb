module ContentHelpers
  def description_to_id(description)
    description.gsub(/\s+/, '-').downcase
  end

  def parse_table(html_table)
    rows = html_table.all('tr')
    rows.map{|row| row.all('td|th').map{|c| c.text.strip}}
  end
end
World(ContentHelpers)
