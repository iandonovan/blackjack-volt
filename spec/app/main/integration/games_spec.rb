# An example integration spec, this will only be run if ENV["BROWSER"] is
# specified.  Current values for ENV["BROWSER"] are "firefox" and "phantom"
require "spec_helper"

describe "game flow", type: :feature do
  before { visit "/" }
  describe "win/loss record" do
    it "shows initial score" do
      expect(page.text).to match(/You are \d and \d/)
    end
  end

  describe "dealer hand" do
    let(:dealer_cards) { find(".dealer-cards .card-set") }
    it "does not display dealer's total" do
      expect(dealer_cards).to have_content("Dealer:")
      # This will fail if the dealer has blackjack. Gotta stub.
      expect(dealer_cards.text).to_not match(/Dealer: \d{1,2}/)
    end
  end

  describe "player hand" do
    let(:player_cards) { find(".player-cards .card-set") }
    it "shows the player's total" do
      expect(player_cards.text).to match(/Your hand: \d{1,2}/)
    end
  end

  describe "hitting" do
    let(:player_hand) { find(".player-cards .card-set .hand-lineup") }
    it "gives the player a new card" do
      expect{ click_button('Hit') }.
        to change { player_hand.text.length }.by(4),
        "Adds a space, rank, space, suit"
    end
  end

  describe "staying" do
    let(:dealer_cards) { find(".dealer-cards .card-set") }
    let(:dealer_hand) { find(".dealer-cards .card-set .hand-lineup") }
    it "reveals computer's hidden card" do
      expect{ click_button("Stay") }.
        to change{ dealer_hand.text.count("*") }.by(-1),
        "The face-down card is an asterisk. On reveal, it's not."
    end

    it "shows the dealer total" do
      click_button("Stay")
      expect(dealer_cards.text).to match(/Dealer: \d{1,2}/)
    end
  end

end
