class AttributeValidator < Validator

  # Supported operators (this is an array of strings)
  @@operators = ['<', '>', '=', '>=', '<=']


  # This validator checks attributes against a set of rules (each rule having an operator and value)
  # Available attributes to check
  # - All attributes from the result object
  # - All attributes from the sport session object
  # - n_participants : Number of participants that were joining the sport event
  # -
  #


  # def initialize(participant_result)
  #   super(participant_result)
  #   init
  # end

  def set_participant_result(participant_result)
    super(participant_result)
    init
  end


  # Validate data against rules
  # @param rules Hash or JSON string

  def validate(rules)

    if rules.instance_of? String
      rules = JSON.parse(rules)
    end

    begin
      # Check each rule (AND condition, each check must pass)
      rules.each do |rule|

        attribute = rule['attribute'].to_s
        operator = rule['operator'].to_s

        if not @@operators.include?(operator)
          raise "Operator #{operator} not supported by AttributeValidator"
        end

        print 'Inspect attributes...'
        print @attributes.to_yaml

        if not @attributes.has_key?(attribute)
          raise "Attribute #{attribute} not defined"
        end

        value = @attributes[attribute]
        if value.is_a?(TrueClass) or value.is_a?(FalseClass)
          value = (value.is_a?(TrueClass)) ? 1 : 0
        else
          value = value.to_f;
        end

        value_compare = rule['value'].to_f
        if not compare(value, operator, value_compare)
          return false
        end
      end

      true
    rescue => e
      puts e
      false
    end

  end


  private

  # Compare value 1 against value2 with the given operator
  #
  #
  def compare(value1, operator, value2)
    case operator
      when '<'
        result = value1 < value2
      when '>'
        result = value1 > value2
      when '='
        result = value1 == value2
      when '<='
        result = value1 <= value2
      when '>='
        result = value1 >= value2
      else
        result = false
    end

    result
  end


  # Initialize all attributes
  #
  #
  def init
    @attributes = @participant_result.attributes
    @attributes.merge(@participant_result.sport_session.attributes)
    @attributes['n_participants'] = @participant_result.sport_session.n_participants
  end

end