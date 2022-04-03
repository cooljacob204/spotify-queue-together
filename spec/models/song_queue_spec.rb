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

    describe '#pop_song' do
      it 'returns the next song in the queue' do
        song = { 'test' => 'song' }
        described_class.new(id).add_to_queue(song)

        expect(described_class.new(id).pop_song).to eq song
      end

      it 'removes the song from the queue' do
        song = { 'test' => 'song' }
        described_class.new(id).add_to_queue(song)

        described_class.new(id).pop_song

        expect(REDIS_DB.lpop("song_queue:#{id}")).to be_nil
      end
    end
  end
end
