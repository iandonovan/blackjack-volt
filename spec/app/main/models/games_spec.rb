require 'spec_helper'

describe Game do
  it { is_expected.to respond_to(:deck) }
  it { is_expected.to respond_to(:cards) }
  it { is_expected.to respond_to(:player) }
  it { is_expected.to respond_to(:winner_string) }
  it { is_expected.to respond_to(:current_player) }

  let(:player) { Player.new(wins: 5, losses: 5) }
  subject(:game) { Game.new(player: player).fresh_game }
  let(:ten) { Card.new(suit: "diams", rank: 10) }
  let(:six) { Card.new(suit: "clubs", rank: 6) }
  let(:ace) { Card.new(suit: "spades", rank: "A") }

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
      expect{ game.computer_turn }.
        to change{ game.current_player }.to("computer")
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
        game.cards = [ten, ten]
        expect(game).to_not receive(:deal_card_to)
        game.computer_turn
      end
    end

    context "when computer does not bust" do
      it "determines the winner" do
        game.cards = [ten, ten]
        expect(game).to receive(:determine_winner)
        game.computer_turn
      end
    end
  end

  describe "#check_for_blackjack!" do
    context "when computer has blackjack" do
      let!(:hand) { game.cards = [ten, ace] }
      it "gives the player a loss" do
        expect{ game.send(:check_for_blackjack!) }.
          to change{ player.losses }.by(1)
      end

      it "sets the winner as the computer" do
        expect{ game.send(:check_for_blackjack!) }.
          to change{ game.winner_string }.
            to("Computer has blackjack!")
      end

      it "sets the turn to the computer to reveal card" do
        expect{ game.send(:check_for_blackjack!) }.
          to change{ game.current_player }.to("computer")
      end
    end

    context "when computer does not have blackjack" do
      let!(:hand) { game.cards = [ten, six] }
      it "does not set a blackjack win" do
        expect(game).to_not receive(:set_blackjack_win)
        game.send(:check_for_blackjack!)
      end
    end
  end

  describe "#check_bust" do
    context "when the hand is over 21" do
      let!(:hand) { [ten, ten, ten] }
      context "when it's the player's turn" do
        it "sets the computer as the winner" do
          player.cards = hand
          expect(game).to receive(:set_computer_win)
          game.send(:check_bust, player.cards)
        end
      end

      context "when it's the computer's turn" do

      end
    end

    context "when the hand is under 21" do

    end
  end

end
