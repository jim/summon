require 'rubygems'
gem 'test-unit'
require 'test/unit'
require 'active_support'
require 'active_support/test_case'
require 'active_record'
require 'factory_girl'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'summon'

ActiveRecord::Base.logger = Logger.new(File.open('test.log', 'a'))
ActiveRecord::Base.logger.level = Logger::DEBUG
ActiveRecord::Base.colorize_logging = false

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => ":memory:"
)

ActiveRecord::Schema.define do
  create_table :boxes, :force => true do |t|
    t.string :name
    t.integer :depth
  end
  create_table :corners, :force => true do |t|
    t.integer :box_id
    t.boolean :sharp
  end
  create_table :compartments, :force => true do |t|
    t.integer :box_id
    t.boolean :hidden
  end
  create_table :handles, :force => true do |h|
    h.integer :compartment_id
    h.boolean :metal
  end
  create_table :secrets, :force => true do |s|
    s.integer :compartment_id
    s.boolean :valuable
  end
end

class Corner < ActiveRecord::Base; end
class Secret < ActiveRecord::Base; end
class Handle < ActiveRecord::Base; end

class Compartment < ActiveRecord::Base
  has_many :secrets
  has_one :handle
end

class Box < ActiveRecord::Base
  has_many :compartments
  has_many :corners
end

Factory.define(:box) do |b|
  b.name 'A box'
  b.depth 12
end

Factory.define(:corner) do |c|
  c.sharp true
end

Factory.define(:compartment) do |c|
  c.hidden true
end

Factory.define(:handle) do |h|
  h.metal true
end

Factory.define(:secret) do |c|
  c.valuable true
end