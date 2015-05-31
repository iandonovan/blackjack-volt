class Game < Volt::Model
  field :deck
  field :cards
  field :player
  field :winner_string, String
  field :current_player, String

  SUITS = %w{ spades hearts clubs diams }
  RANKS = %w{ 2 3 4 5 6 7 8 9 10 J Q K A }

  def deal_hands
    self.deck = build_deck.shuffle
    self.player.cards, self.cards = [], []
    self.winner_string = nil
    2.times do
      deal_card_to(player.cards)
      deal_card_to(self.cards)
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

  def computer_turn
    self.current_player == "computer"
    deal_card_to(self.cards) until total(self.cards) >= 17
    winner_string = get_winner_string
  end

  def player_turn?
    self.current_player != "computer"
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

  def get_winner_string
    if total(self.cards) > 21 || total(player.cards) > total(self.cards)
      "You Win!"
    else
      "Computer Wins!"
    end
  end

end
