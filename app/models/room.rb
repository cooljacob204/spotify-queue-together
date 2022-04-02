class Room
  class << self
    def create
      Array.new(5){[*"A".."Z", *"0".."9"].sample}.join
    end
  end
end
