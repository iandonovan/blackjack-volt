class Game < Volt::Model
  field :deck
  field :player_hand
  field :dealer_hand

  SUITS = %w{ spades hearts clubs diams }
  RANKS = %w{ 2 3 4 5 6 7 8 9 10 J Q K A }

  def deal_hands
    self.deck = build_deck.shuffle
    self.player_hand, self.dealer_hand = [], []
    2.times do
      deal_card_to(self.player_hand)
      deal_card_to(self.dealer_hand)
    end
    self
  end

  private

  def build_deck
    deck = []
    SUITS.each do |suit|
      RANKS.each do |rank|
        card = Card.new(suit: suit, rank: rank)
        deck << card
      end
    end
    deck
  end

  def deal_card_to(hand)
    hand << self.deck.pop
  end
end
