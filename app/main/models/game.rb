class Game < Volt::Model
  field :deck
  field :cards
  field :player
  field :winner_string, String
  field :current_player, String

  SUITS = %w{ spades hearts clubs diams }
  RANKS = %w{ 2 3 4 5 6 7 8 9 10 J Q K A }

  def clean_state_vars!
    self.deck = build_deck.shuffle
    self.player.cards, self.cards = [], []
    self.winner_string, self.current_player = nil, nil
  end

  def fresh_game
    clean_state_vars!
    2.times do
      deal_card_to(player.cards)
      deal_card_to(self.cards)
    end
    check_for_blackjack!
    self
  end

  def deal_card_to(hand)
    hand << self.deck.pop
    check_bust(hand)
  end

  def total(hand)
    values = hand.map{ |card| card.value }
    values = check_ace_bust(values)
    high_total = values.inject(:+)
  end

  def computer_turn
    self.current_player = "computer"
    deal_card_to(self.cards) until total(self.cards) >= 17
    determine_winner if self.winner_string.blank?
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

  def check_for_blackjack!
    set_blackjack_win if total(self.cards) == 21
  end

  def check_bust(hand)
    if total(hand) > 21
      if current_player == "computer"
        set_player_win
      else
        set_computer_win
      end
    end
  end

  def check_ace_bust(values)
    if values.inject(:+) > 21 && values.include?(11)
      values[values.index(11)] = 1
      check_ace_bust(values)
    end
    values
  end

  def determine_winner
    if total(self.cards) == total(player.cards)
      set_tie
    elsif total(self.cards) > 21 || total(player.cards) > total(self.cards)
      set_player_win
    else
      set_computer_win
    end
  end

  def set_tie
    player.losses += 1
    self.winner_string = "Tie goes to the dealer!"
  end

  def set_player_win
    player.wins += 1
    self.winner_string = "You win!"
  end

  def set_computer_win
    player.losses += 1
    self.winner_string = "Computer wins!"
    self.current_player = "computer"
  end

  def set_blackjack_win
    player.losses += 1
    self.winner_string = "Computer has blackjack!"
    self.current_player = "computer"
  end

end
