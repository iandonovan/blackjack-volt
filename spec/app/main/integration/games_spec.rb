# An example integration spec, this will only be run if ENV["BROWSER"] is
# specified.  Current values for ENV["BROWSER"] are "firefox" and "phantom"
require "spec_helper"

describe "game flow", type: :feature do
  before { visit "/" }
  describe "win/loss record" do
    it "shows initial score" do
      expect(page).to have_content("You are 0 and 0")
    end

    it "tracks victories"
      # the_page._game.player.wins = 1
      # expect(page).to have_content("You are 1 and 0")
    # end

    it "tracks losses"
  end

  describe "dealer hand" do
    it "shows the face-down card as an asterisk" do
      expect(page).to have_content("*")
    end

    it "does not display dealer's total" do
      expect(page).to have_content("Dealer:")
    end
  end

  describe "player hand" do
    it "shows the player's two cards"

    it "shows the player's total" do
      expect(page.text).to match(/Your hand: \d{1,2}/)
    end
  end

end
