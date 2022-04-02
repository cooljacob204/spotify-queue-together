class Room
  attr_reader :id

  class << self
    def create
      new(Array.new(5) { [*'A'..'Z', *'0'..'9'].sample }.join)
    end
  end

  def initialize(id)
    @id = id
  end
end
