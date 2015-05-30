class Card < Volt::Model
  field :suit, String
  field :rank, String

  def to_s
    rank + suit[0]
  end
end
