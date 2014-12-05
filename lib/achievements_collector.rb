require 'json'
#
# Helper module to collect all achievements by means of
# the achievement method.
# Just a dsl. Why? I like dsl...
#
module AchievementsCollector

  # Defines the context where the achievements are created.
  # This allows to call the methods like title, description etc. inside a closure on this instance.
  #
  class DefinitionContext
    attr_writer :title, :description, :points, :rules, :validator_id, :sport, :validator

    def initialize(params={})
      set_values(params)
    end

    def set_values(params)
      params.each { |k,v| instance_variable_set("@#{k}", v) }
    end

    def method_missing(name, *value, &block)
      begin
        instance_variable_set("@#{name}",*value)
      rescue
        instance_variable_get("@#{name}")
      end
    end

    def to_h
      a_hash = Hash[instance_values.map {|k,v| [k.to_sym,v]}]
      a_hash[:rules] = a_hash[:rules].to_json
      a_hash
    end

    def to_s
      "title:\t\t#{@title}\ndescription:\t#{@description}\npoints:\t\t#{@points}\nsport:\t\t#{@sport}\nvalidator:\t#{@validator}\n\n\n"
    end

    alias_method :to_hash, :to_h
  end

  # Collects an achievement that is defined using a ruby hash.
  #
  # ====Example
  # achievement do
  # { title: 'achievement title',
  #   description: 'foo bar',
  #   etc...
  # }
  # end
  #
  def achievement(&block)
    @achievements ||= []
    context = DefinitionContext.new
    achievement_hash = context.instance_eval(&block)

    if achievement_hash.is_a? Hash
      context.set_values achievement_hash
    end

    @achievements << context
  end

  # Lists all collected achievements
  def list(key=nil)
    if key
      @achievements.map {|achievement| achievement[key] }
    else
      @achievements
    end
  end

end