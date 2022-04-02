# spec/models/auction_spec.rb

require 'rails_helper'

RSpec.describe Room do
  describe '.create' do
    it 'returns an id for a room' do
      expect(described_class.create).to be_a String
    end
  end
end
