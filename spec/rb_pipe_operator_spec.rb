# frozen_string_literal: true

RSpec.describe RbPipeOperator do
  describe '.enable' do
    it 'evaluates a code' do
      actual = RbPipeOperator.enable do
        [1, 2] .|> -> x { x.sum }
      end

      expect(actual).to eq 3
    end

    it 'evaluates a code that uses the method chain' do
      actual = RbPipeOperator.enable do
        [1, 2] .|> -> x { x.sum } .|> -> x { x * 2 }
      end

      expect(actual).to eq 6
    end

    it 'evaluates a code that uses the variable' do
      actual = RbPipeOperator.enable do
        scale = 2
        [1, 2] .|> -> x { x.sum } .|> -> x { x * scale }
      end

      expect(actual).to eq 6
    end

    it 'evaluates a code that uses the closure' do
      scale = 2
      actual = RbPipeOperator.enable do
        [1, 2] .|> -> x { x.sum } .|> -> x { x * scale }
      end

      expect(actual).to eq 6
    end

    it 'evaluates a code that uses the proc object' do
      a = -> x { x.sum }
      b = -> x { x * 2 }

      actual = RbPipeOperator.enable do
        [1, 2] .|> a .|> b
      end

      expect(actual).to eq 6
    end
  end
end
