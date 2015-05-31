class Card < Volt::Model
  field :suit, String
  field :rank, String

  TENS = %w( J Q K )
  
  def value
    if TENS.include?(self.rank)
      10
    elsif self.rank == "A"
      11
    else
      self.rank.to_i
    end
  end
end
