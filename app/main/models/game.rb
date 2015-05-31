class Game < Volt::Model
  field :deck
  field :player_cards
  field :dealer_cards

  SUITS = %w{ spades hearts clubs diams }
  RANKS = %w{ 2 3 4 5 6 7 8 9 10 J Q K A }

  def deal_hands
    self.deck = build_deck.shuffle
    self.player_cards = []
    self.dealer_cards = []
    2.times do
      deal_card_to(self.player_cards)
      deal_card_to(self.dealer_cards)
    end
    self
  end

  def deal_card_to(hand)
    hand << self.deck.pop
  end

  def total(hand)
    values = hand.map{ |card| card.value }
    values = check_ace_bust(values)
    high_total = values.inject(:+)
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

  def check_ace_bust(values)
    if values.inject(:+) > 21 && values.include?(11)
      values[values.index(11)] = 1
      check_ace_bust(values)
    end
    values
  end

end
