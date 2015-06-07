require 'spec_helper'

describe Game do
  it { is_expected.to respond_to(:deck) }
  it { is_expected.to respond_to(:cards) }
  it { is_expected.to respond_to(:player) }
  it { is_expected.to respond_to(:winner_string) }
  it { is_expected.to respond_to(:current_player) }

  let(:ten) { Card.new(suit: "diams", rank: 10) }
  let(:eight) { Card.new(suit: "hearts", rank: 8) }
  let(:six) { Card.new(suit: "clubs", rank: 6) }
  let(:ace) { Card.new(suit: "spades", rank: "A") }
  let(:player) { Player.new(wins: 5, losses: 5, cards: [ten, eight]) }
  subject!(:game) { Game.new(player: player).fresh_game }

  before(:each) do
    game.cards = [ten, eight]
    player.cards = [eight, six]
  end

  describe "#clean_state_vars!" do
    it "initializes deck" do
      game.clean_state_vars!
      expect(game.deck).to be_a(Volt::ArrayModel)
      expect(game.deck.size).to eq(52)
    end

    it "initializes cards" do
      expect(game.cards).to be_a(Volt::ArrayModel)
      expect(player.cards).to be_a(Volt::ArrayModel)
      game.clean_state_vars!
      expect(game.cards.empty?).to eq(true)
      expect(game.cards.empty?).to eq(true)
    end

    it "cleans winner string" do
      game.winner_string = "Winner"
      expect{ game.clean_state_vars! }.
        to change { game.winner_string }.to("")
    end

    it "initializes current player" do
      game.current_player = "computer"
      expect{ game.clean_state_vars! }.
        to change{ game.current_player }.to("player")
    end
  end

  describe "#fresh_game" do
    it "calls clean_state_vars!" do
      expect(game).to receive(:clean_state_vars!).
        exactly(1).times.and_call_original
      game.fresh_game
    end

    it "deals the player and computer a hand" do
      expect(game).to receive(:deal_card_to).
        exactly(4).times.and_call_original
      game.fresh_game
      expect(player.cards.size).to eq(2)
      expect(game.cards.size).to eq(2)
    end

    it "checks for computer's blackjack" do
      expect(game).to receive(:check_for_blackjack!).
        exactly(1).times
      game.fresh_game
    end
  end

  describe "#deal_card_to(hand)" do
    it "deals a card to the player" do
      expect{ game.deal_card_to(player.cards) }.
        to change{ game.player.cards.size }.by(1)
    end

    it "deals a card to the computer" do
      expect{ game.deal_card_to(game.cards) }.
        to change{ game.cards.size }.by(1)
    end

    it "checks for a bust" do
      expect(game).to receive(:check_bust).
        exactly(1).times
      game.deal_card_to(game.cards)
    end
  end

  describe "total(hand)" do
    it "tallies the card values" do
      hand = [ten, six]
      expect(game.total(hand)).to eq(16)
    end

    context "with ace in hand" do
      it "checks for ace adjustment" do
        hand = [ten, ace]
        expect(game).to receive(:adjust_ace).
          exactly(1).times.and_call_original
        expect(game.total(hand)).to eq(21)
      end

      it "counts it as 11 to maximize score" do
        hand = [ace, six]
        expect(game.total(hand)).to eq(17)
      end

      it "counts it as 1 to avoid bust" do
        hand = [ace, six, ten]
        expect(game.total(hand)).to eq(17)
      end
    end

    context "without ace in hand" do
      it "does not check for ace adjustment" do
        hand = [ten, six]
        expect(game).to_not receive(:adjust_ace)
        expect(game.total(hand)).to eq(16)
      end
    end
  end

  describe "computer_turn" do
    it "sets the current player to be the computer" do
      game.computer_turn
      expect(game.current_player).to eq("computer")
    end

    context "when computer has less than 17" do
      it "deals computer a card" do
        game.cards = [ten, six]
        expect(game).to receive(:deal_card_to).
          with(game.cards).and_call_original
        game.computer_turn
      end
    end

    context "when computer has 17 or higher" do
      it "does not deal computer a card" do
        game.cards = [ten, ace]
        expect(game).to_not receive(:deal_card_to)
        game.computer_turn
      end
    end

    context "when computer does not bust" do
      it "determines the winner" do
        game.winner_string = ""
        expect(game).to receive(:determine_winner)
        game.computer_turn
      end
    end
  end

  describe "#check_for_blackjack!" do
    context "when computer has blackjack" do
      let!(:comp_hand) { game.cards = [ten, ace] }
      let!(:player_hand) { player.cards = [ten, eight] }
      it "gives the player a loss" do
        expect{ game.send(:check_for_blackjack!) }.
          to change{ player.losses }.by(1)
      end

      it "sets the winner as the computer" do
        game.send(:check_for_blackjack!)
        expect(game.winner_string).to eq("Computer has blackjack!")
      end

      it "sets the turn to the computer to reveal card" do
        game.send(:check_for_blackjack!)
        expect(game.current_player).to eq("computer")
      end
    end

    context "when computer does not have blackjack" do
      it "does not set a blackjack win" do
        expect(game).to_not receive(:set_blackjack_win)
        game.send(:check_for_blackjack!)
      end
    end
  end

  describe "#check_bust" do
    context "when the hand is over 21" do
      let(:hand) { [ten, six, eight] }
      context "when it's the player's turn" do
        it "sets the computer as the winner" do
          game.current_player = "player"
          expect(game).to receive(:set_computer_win)
          player.cards = hand
          game.send(:check_bust, player.cards)
        end
      end

      context "when it's the computer's turn" do
        it "sets the player as the winner" do
          game.current_player = "computer"
          expect(game).to receive(:set_player_win)
          game.cards = hand
          game.send(:check_bust, game.cards)
        end
      end
    end

    context "when the hand is under 21" do
      let(:hand) { [ten, eight] }
      it "returns nil" do
        game.cards = hand
        expect(game.send(:check_bust, game.cards)).
          to eq(nil)
      end
    end
  end

  describe "#adjust_ace" do
    context "when the hand is over 21" do
      let(:values) { [ ace, ten, eight].map{ |card| card.value } }
      it "recurses" do
        expect(game).to receive(:adjust_ace).
          exactly(2).times.and_call_original
        game.send(:adjust_ace, values)
      end

      it "changes the ace value to 1" do
        expect(game.send(:adjust_ace, values)).
          to eq([1, 10, 8])
      end
    end

    context "when the hand is under 21" do
      let(:values) { [ace, eight].map{ |card| card.value } }
      it "returns values unchanged" do
        expect(game.send(:adjust_ace, values)).
          to eq(values)
      end
    end
  end

  describe "#determine_winner" do
    let(:hand) { [ten, eight] }
    let(:blackjack) { [ten, ace] }
    let(:bust) { [ ten, eight, six] }
    context "when there's a tie" do
      it "invokes #set_tie" do
        game.cards = hand
        player.cards = hand
        expect(game).to receive(:set_tie).exactly(1).times
        game.send(:determine_winner)
      end
    end

    context "when the player wins" do
      context "because the dealer busted" do
        it "invokes #set_player_win" do
          game.cards = bust
          player.cards = hand
          expect(game).to receive(:set_player_win).exactly(1).times
          game.send(:determine_winner)
        end
      end

      context "because the player's total is higher" do
        it "invokes #set_player_win" do
          game.cards = hand
          player.cards = blackjack
          expect(game).to receive(:set_player_win).exactly(1).times
          game.send(:determine_winner)
        end
      end
    end

    context "when the computer wins" do
      it "invokes #set_computer_win" do
        game.cards = blackjack
        player.cards = hand
        expect(game).to receive(:set_computer_win).exactly(1).times
        game.send(:determine_winner)
      end
    end
  end

  describe "#set_tie" do
    it "gives the player a loss" do
      expect{ game.send(:set_tie) }.
        to change{ player.losses }.by(1)
    end

    it "sets the winner string" do
      expect{ game.send(:set_tie) }.
        to change{ game.winner_string }.
          to("Tie goes to the dealer!")
    end
  end

  describe "#set_player_win" do
    it "gives the player a win" do
      expect{ game.send(:set_player_win) }.
        to change{ player.wins }.by(1)
    end

    it "sets the winner string" do
      expect{ game.send(:set_player_win) }.
        to change{ game.winner_string }.to("You win!")
    end
  end

  describe "#set_computer_win" do
    it "gives the player a loss" do
      expect{ game.send(:set_computer_win) }.
        to change{ player.losses }.by(1)
    end

    it "sets the winner string" do
      game.send(:set_computer_win)
      expect(game.winner_string).to eq("Computer wins!")
    end

    it "sets the current turn to computer" do
      game.send(:set_computer_win)
      expect(game.current_player).to eq("computer")
    end
  end

  describe "#set_blackjack_win" do
    it "gives the player a loss" do
      expect{ game.send(:set_blackjack_win) }.
        to change{ player.losses }.by(1)
    end

    it "sets the winner string" do
      expect{ game.send(:set_blackjack_win) }.
        to change{ game.winner_string }.
          to("Computer has blackjack!")
    end

    it "sets the current turn to computer" do
      game.send(:set_blackjack_win)
      expect(game.current_player).to eq("computer")
    end
  end

end
