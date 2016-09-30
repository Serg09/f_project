class Hash
  def select_keys(*keys)
    select{|k, v| keys.include?(k)}
  end
end
