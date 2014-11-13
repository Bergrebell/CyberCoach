class Validator < ActiveRecord::Base

  # Must be implemented by subclass
  def validate(rules, data)
    raise 'Implement!'
  end

end