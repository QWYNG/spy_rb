require 'test_helper'
require_relative '../lib/spy'

class FakeClass
  def age
    25
  end

  def self.hello_world
    'hello world'
  end

  def self.repeat(arg)
    arg
  end
end

class SpyTest < Minitest::Spec
  describe Spy do
    describe '.on' do
      after { Spy.restore :all }

      describe 'with no arguments' do
        it 'throws an ArgumentError' do
          assert_raises ArgumentError do
            Spy.on
          end
        end
      end

      describe 'with one argument' do
        it 'throws an ArgumentError' do
          assert_raises ArgumentError do
            Spy.on Array
          end
        end
      end

      it 'modifies the original method of an object' do
        obj = FakeClass.new
        old_method = obj.method(:age)
        Spy.on(obj, :age)
        assert obj.method(:age) != old_method
      end

      it 'modifies the class method of a class' do
        klass = FakeClass
        old_method = FakeClass.method(:hello_world)
        Spy.on(FakeClass, :hello_world)
        assert FakeClass.method(:hello_world) != old_method
      end

      it 'should not modify the spied methods return value' do
        Spy.on(FakeClass, :hello_world)
        assert FakeClass.hello_world == 'hello world'
        
        instance = FakeClass.new
        Spy.on(instance, :age)
        assert instance.age == 25
      end

      it 'throws if the object is missing the method to spy on' do
        assert_raises NameError do
          Spy.on(FakeClass, :this_does_not_exist)
        end
      end

      it 'accepts an instance option which modifies the method for instances of the class' do
        skip
      end

      it 'throws if the method is already being spied' do
        Spy.on(FakeClass, :hello_world)
        assert_raises Spy::AlreadySpiedError do
          Spy.on(FakeClass, :hello_world)
        end
      end

      it 'returns a Spy instance' do
        assert Spy.on(FakeClass, :hello_world).is_a? Spy::Instance
      end

      it 'allows you to spy on multiple methods on the same object' do
        skip
        Spy.on(FakeClass, :hello_world)
        Spy.on(FakeClass, :repeat)
      end
    end

    describe '.restore' do
      it 'restores all of the spied methods with the :all argument' do
        obj = FakeClass.new
        obj_method = obj.method(:age)
        klass = FakeClass
        klass_method = klass.method(:hello_world)

        Spy.on(obj, :age)
        Spy.on(klass, :hello_world)

        Spy.restore(:all)
        
        assert obj.method(:age) == obj_method
        assert klass.method(:hello_world) == klass_method
      end

      it 'restores the originally spied method of an object' do
        obj = FakeClass.new
        obj_method = obj.method(:age)

        Spy.on(obj, :age)

        Spy.restore(obj, :age)

        assert obj.method(:age) == obj_method
      end

      it 'throws if the method is not being spied' do
        skip
      end
    end

    describe '.with_args' do
      after { Spy.restore :all }

      it 'should only count times when the args match' do
        spy = Spy.on(FakeClass, :repeat).with_args('hello')
        assert spy.call_count == 0
        FakeClass.repeat 'yo'
        assert spy.call_count == 0
        FakeClass.repeat 'hello'
        assert spy.call_count == 1
        FakeClass.repeat 'yo'
        assert spy.call_count == 1
        FakeClass.repeat 'hello'
        assert spy.call_count == 2
      end
    end
   
    describe '.call_count' do
      after { Spy.restore :all }

      it 'should initially be zero' do
        spy = Spy.on(FakeClass, :hello_world)
        assert spy.call_count == 0
      end

      it 'should properly increment' do
        spy = Spy.on(FakeClass, :hello_world)
        FakeClass.hello_world
        assert spy.call_count == 1
        FakeClass.hello_world
        assert spy.call_count == 2
      end
    end

    it 'should accept a block' do
      skip
      #Spy.on(FakeClass, :hello_world).each_call {|*args| ...}
    end
  end
end
