# extend the Hash to include to_param string method
# a value string can also be a Hash
class Hash
  def parameter_string
    output_string = ''
    sort_by { |key, value | key} .each { |key, value| output_string += "#{key}=#{value}&" }  # create name=value strings connected by &
    output_string.chomp!("&")
  end
end