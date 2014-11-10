class AttributeValidator < Validator

  # Supported operators (this is an array of strings)
  @@operators = %w(< > =)


  # Validate data against rules
  # @var data Hash
  # @var rules Hash or JSON string

  def validate(rules, data)

    rules = rules.instance_of? String ? JSON.parse(rules) : rules

    rules.each do |rule|

      if not @@operators.include?(rule.operator)
        raise "Operator #{rule.operator} not supported by AttributeValidator"
      end

      # Holds the attribute to check against data
      result = true
      value = data[rules[:attribute].to_sym]

      case rule.operator
        when '<'
          result = value < rule[:value]
        when '>'
          result = value > rule[:value]
        when '='
          result = value == rule[:value]
      end

      if not result
        false
      end

    end

    true

  end

end