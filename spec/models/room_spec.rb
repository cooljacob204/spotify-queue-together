require 'rails_helper'

RSpec.describe Room do
  describe '.create' do
    it 'returns a room with a random id' do
      expect(described_class.create.id).to be_a String
    end
  end
end
