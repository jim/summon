require 'factory_girl'

module Summon

  class << self
    attr_accessor :noisy
  end
  self.noisy = false
    
  class Conjure

    attr :parent

    def initialize(parent)
      @parent = parent
    end

    def log(string, force = false)
      if (parent.nil? && Summon.noisy) || force
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
      
      quantity = args.first || 1
      quantity = quantity.to_a[rand(quantity.to_a.size)] if quantity.is_a?(Range)
      options = args.extract_options!

      log "** Summoning #{quantity} #{name.to_s.pluralize} "
      
      # time = Benchmark.measure do
        quantity.times do
        
          log '.'
        
          attributes = process_options.call(options)
                
          if parent.nil?
            child = Factory(name, attributes)
          else
            association = @parent.class.reflect_on_association(name.to_sym)
            raise "Association #{name} not found on #{@parent.class.to_s}" unless association
          
            child = case association.macro
              when :has_one:
                parent.send("#{name}=", Factory(name.to_s.singularize, attributes))
              when :belongs_to:
                parent.send("#{name}=", Factory(name.to_s.singularize, attributes))
              when :has_many:
                parent.send(name).create(Factory.attributes_for(name.to_s.singularize, attributes))
              when :has_and_belongs_to_many:
                object = Factory(name.to_s.singularize, attributes)
                parent.send(name).send(:<<, object)
                object
              else
                raise "#{association.macro} macros are not supported"
            end
          end
          yield Conjure.new(child) if block_given?
        end
      # end
      # log " #{(time.real*1000/quantity).round / 1000.0}"
      log "\n"
    end
  end
  
end

def Summon(factory, quantity, options = {}, &block)
  Summon::Conjure.new(nil).send(factory, quantity, options, &block)
end