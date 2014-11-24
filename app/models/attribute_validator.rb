class AttributeValidator < Validator

  # Supported operators (this is an array of strings)
  @@operators = ['<', '>', '=']


  # Validate data against rules
  # @var data Hash
  # @var rules Hash or JSON string

  def validate(rules, data)

    if rules.instance_of? String
      rules = JSON.parse(rules)
    end

    rules.each do |rule|

      #print "A rule: " + rule['attribute'] + " " + rule['value'] + " " + rule['operator']
      print "Data: " + data.inspect

      if not @@operators.include?(rule['operator'])
        raise "Operator #{rule['operator']} not supported by AttributeValidator"
      end

      # Holds the attribute to check against data
      result = true
      value = data[rule['attribute'].to_s]

      case rule['operator']
        when '<'
          result = value < rule['value'].to_f
        when '>'
          result = value > rule['value'].to_f
        when '='
          result = value == rule['value'].to_f
      end

      if not result
        false
      end

    end

    true

  end

end