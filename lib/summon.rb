require 'factory_girl'

module Summon
  
  class Conjure

    attr :parent

    def initialize(parent)
      @parent = parent
    end

    def log(string)
      if parent.nil?
        printf string; $stdout.flush
      end
    end

    def method_missing(name, *args, &block)
      
      process_options = lambda do |o|
        o.inject({}) do |hash, pair| key, value = pair
          value = case value
            when Range: value.to_a[rand(value.to_a.size)]
            when Array: value[rand(value.size)]
            when Proc: value.call
            else value
          end
          hash[key] = value
          hash
        end
      end
      
      quantity = args.first      
      quantity = quantity.to_a[rand(quantity.to_a.size)] if quantity.is_a?(Range)
      options = args.extract_options!

      log "** Summoning #{quantity} #{name.to_s.pluralize} "

      quantity.times do
        
        log '.'
        
        attributes = process_options.call(options)
        
        if parent.nil?
          child = Factory(name, attributes)
        else
          child = parent.send(name).create(Factory.attributes_for(name.to_s.singularize, attributes))
        end
        yield Conjure.new(child) if block_given?
      end
      log "\n"
    end
  end
  
end

def Summon(factory, quantity, options = {}, &block)
  Summon::Conjure.new(nil).send(factory, quantity, options, &block)
end