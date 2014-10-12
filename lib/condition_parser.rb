#
# This class parses conditions encoded as json strings to a validation function.
#
# It is based on the Reverse Polish notation and the Shunting-yard algorithm.
# More details see: 	1) http://en.wikipedia.org/wiki/Reverse_Polish_notation
# 						      2) http://en.wikipedia.org/wiki/Shunting-yard_algorithm
#
#
class ConditionParser
  #
  # This method takes as argument a hash with the following properties:
  # conditions: a list of conditions, assignments: a hash of assignments.
  #
  # The symbols :and, :not and :or are used as connectives for building more complex conditions.
  #
  # ====Example
  # x1 = { value: 10, op: '<', attribute: 'km'}
  # x2 = { value: 20, op: '>', attribute: 'km'}
  # x3 = { value: 16, op: '!=', attribute: 'km'}
  # conditions = [:<,x1,:and,x2,:>,:and,x3]
  # assignments = { km: 16}
  #
  # parser = CondtionParser.new
  # parser.parse conditions: conditions, assignments: assignments
  #
  def parse(params)
    conditions, assignments = params[:conditions], params[:assignments]

    # map all keys to symbols
    assignments = Hash[assignments.map {|k,v| [k.to_sym,v]}]

    # map (,),and,not,or to symbols that are internally used.
    conditions = preprocessing(conditions)

    # apply Shunting-yard algorithm
    parser = Infix2Postfix.new
    conditions = parser.parse(conditions)

    # map to boolean functions
    boolean_functions = to_boolean_functions(conditions, assignments)

    # apply all boolean functions
    booleans = boolean_functions.map do |boolean_function|
      if boolean_function.kind_of?(Symbol) # if true its a symbol like :not, :and, :or
        boolean_function
      else #otherwise its a boolean function
        boolean_function.call # apply it
      end
    end
    # apply Reverse Polish algorithm and return a closure which returns the final result.
    return ->() { eval(booleans) }
  end


  private

  def preprocessing(conditions)
    conditions.map do |literal|
      case literal
        when '(' then
          :<
        when ')' then
          :>
        when 'and' then
          :and
        when 'or' then
          :or
        when 'not' then
          :not
        else
          literal
      end
    end
  end

  #
  # Map each condition to a boolean function using the
  # provided assignments for these boolean functions.
  #
  def to_boolean_functions(conditions, assignments)
    conditions = conditions.map do |x|
      if not x.kind_of?(Symbol) # check if its a condition
        operator, condition_value, attribute = x[:op], x[:value], x[:attribute].to_sym
        assignment = assignments[attribute]

        case operator
          when '<' then
            ->() { condition_value < assignment }
          when '>' then
            ->() { condition_value > assignment }
          when '=' then
            ->() { condition_value == assignment }
          when '<=' then
            ->() { condition_value <= assignment }
          when '>=' then
            ->() { condition_value >= assignment }
          when '!=' then
            ->() { condition_value != assignment }
          when 'includes' then
            ->() {  condition_value.include?(assignment) }
          when 'excludes' then
            ->() {  not condition_value.include?(assignment) }
          else
            raise 'Error: op not found!'
        end
      else # otherwise its a symbol
        x
      end
    end
  end

  #
  # Evaluate the conditions in order to get a final boolean value using
  # the Reverse Polish notation.
  #
  def eval(conditions)
    stack = Array.new
    # lookup table
    op_table = {
        or: ->(a, b) { a or b },
        and: ->(a, b) { a and b },
        not: ->(a) { not a },
        num_params: {or: 2, and: 2, not: 1}
    }

    while conditions.size != 0
      v = conditions.first
      conditions.shift # remove first element

      #check if symbol, otherwise its a boolean
      if not v.kind_of?(Symbol)
        stack << v # push boolean on the stack
      else
        # check how many params the op takes
        if op_table[:num_params][v]==2
          o1, o2 = stack.pop, stack.pop #pop two operands
          stack << op_table[v].call(o1, o2)
        else
          o = stack.pop #pop only a single operand
          stack << op_table[v].call(o)
        end
      end
    end
    if stack.size > 1
      raise 'Operand missing!'
    end
    return stack.pop
  end
end

#
# This class translates the infix notation for boolean expressions to
# the Reverse Polish notation using the Shunting-yard algorithm.
#
class Infix2Postfix
  #
  # Based on the source code: http://msoulier.wordpress.com/2009/08/01/dijkstras-shunting-yard-algorithm-in-python/
  # It is translated from python to ruby.
  # Instead of parsing a string it parses a list.
  #

  def initialize
    @stack = []
    @tokens = []
    @postfix = []
  end

  def parse(input)
    tokenize(input)
    @tokens.each do |token|
      if is_operator(token)
        manage_precedence(token)
      else
        if token == :<
          @stack << token
        elsif token == :>
          right_paren
        else
          @postfix << token
        end
      end
    end

    while @stack.size > 0
      operator = @stack.pop
      if operator == :< or operator == :>
        raise 'Parse Error'
      end
      @postfix << operator
    end
    @postfix
  end

  private

  def tokenize(list)
    @tokens = list
    new_tokens = []
    @tokens.each do |token|
      right_p = false
      if token[0] == :<
        new_tokens << :<
        token = token[1..-1]
      end

      if token.length > 0 and token[-1] == :>
        token = token[0...-1]
        right_p = true
      end
      new_tokens << token
      if right_p
        new_tokens << :>
      end
    end

    @tokens = new_tokens
  end

  def is_operator(op)
    [:and,:or,:not].include?(op)
  end

  def manage_precedence(token)
    if token != :not
      while @stack.size > 0
        op = @stack.pop
        if op == :not
          @postfix << op
        else
          @stack << op
          break
        end
      end
    end
    @stack << token
  end

  def right_paren
    found_left = false
    while @stack.size > 0
      top_op = @stack.pop

      if top_op != :<
        @postfix << top_op
      else
        found_left = true
        break
      end
    end

    if not found_left
      raise 'Parse Error: Mismatched parens'
    end

    if @stack.size > 0
      top_op = @stack.pop
      if is_operator(top_op)
        @postfix << top_op
      else
        @stack << top_op
      end
    end
  end

end
