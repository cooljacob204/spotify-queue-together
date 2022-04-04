# spec/models/auction_spec.rb

require 'rails_helper'

RSpec.describe SongQueue do
  describe '.create' do
    let(:id) { 'abc123' }

    before do
      REDIS_DB.flushall
    end

    describe '#add_to_queue' do
      it 'adds to the room queue' do
        song = { 'test' => 'song' }
        described_class.new(id).add_to_queue(song)

        expect(REDIS_DB.rpop("song_queue:#{id}")).to eq song.to_json
      end

      it 'expires the queue after 6 hours' do
        described_class.new(id).add_to_queue({})

        expect(REDIS_DB.ttl("song_queue:#{id}")).to eq 6 * 60 * 60
      end
    end

    describe '#add_to_front_of_queue' do
      it 'adds to the room queue' do
        song = { 'test' => 'song' }
        described_class.new(id).add_to_front_of_queue(song)

        expect(REDIS_DB.lpop("song_queue:#{id}")).to eq song.to_json
      end

      it 'expires the queue after 6 hours' do
        described_class.new(id).add_to_front_of_queue({})

        expect(REDIS_DB.ttl("song_queue:#{id}")).to eq 6 * 60 * 60
      end
    end

    describe '#pop' do
      it 'returns the next song in the queue' do
        song = { 'test' => 'song' }
        described_class.new(id).add_to_queue(song)

        expect(described_class.new(id).pop).to eq song
      end

      it 'removes the song from the queue' do
        song = { 'test' => 'song' }
        described_class.new(id).add_to_queue(song)

        described_class.new(id).pop

        expect(REDIS_DB.lpop("song_queue:#{id}")).to be_nil
      end
    end

    describe '#length' do
      it 'returns the length of the queue' do
        described_class.new(id).add_to_queue({})
        described_class.new(id).add_to_queue({})

        expect(described_class.new(id).length).to eq 2
      end
    end

    describe '#empty?' do
      it 'returns true if the queue is empty' do
        expect(described_class.new(id).empty?).to be true
      end

      it 'returns false if the queue is not empty' do
        described_class.new(id).add_to_queue({})

        expect(described_class.new(id).empty?).to be false
      end
    end

    describe '#clear' do
      it 'clears the queue' do
        described_class.new(id).add_to_queue({})
        described_class.new(id).add_to_queue({})

        described_class.new(id).clear

        expect(described_class.new(id).length).to eq 0
      end
    end

    describe '#list' do
      it 'returns the list of songs in the queue' do
        described_class.new(id).add_to_queue({ 'test' => 'song' })
        described_class.new(id).add_to_queue({ 'test' => 'song2' })

        expect(described_class.new(id).list).to match_array [{ 'test' => 'song' }, { 'test' => 'song2' }]
      end
    end
  end
end
