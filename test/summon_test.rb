require 'test_helper'

class SummonTest < ActiveSupport::TestCase
  
  def setup
    Summon.noisy = false
    Corner.delete_all
    Compartment.delete_all
    Handle.delete_all
    Box.delete_all
    Secret.delete_all
  end

  test "building a number of objects" do
    Summon(:corner, 3)
    assert_equal 3, Corner.count
  end
  
  test "building a variable number of objects" do
    Summon(:corner, 3..5)
    assert_operator 3..5, :===, Corner.count
  end
  
  test "overriding default factory attributes" do
    Summon(:corner, 1, :sharp => false)
    assert_equal false, Corner.first.sharp
  end
  
  test "building has_many associations" do
    Summon(:box, 1) do |b|
      b.corners 3
      b.compartments 2 do |c|
        c.secrets 4
      end
    end
    assert_equal 3, Box.first.corners.count
    assert_equal 3, Corner.count
    assert_equal 2, Box.first.compartments.count
    assert_equal 2, Compartment.count
    assert_equal 8, Secret.count
  end
  
  test "building has_one associations" do
    Summon(:box, 1) do |b|
      b.compartments 2 do |c|
        c.handle
      end
    end
    assert_equal 2, Compartment.count
    assert_equal 2, Handle.count
  end
  
end