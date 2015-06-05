require 'spec_helper'

describe Card do
  it { is_expected.to respond_to(:suit) }
  it { is_expected.to respond_to(:rank) }

  describe "#value" do
    it "is face value for 2-10" do
      (2..10).each do |rank|
        card = Card.new(suit: "clubs", rank: rank)
        expect(card.value).to eq(rank)
      end
    end

    it "is 10 for J, Q, K" do
      %w( J Q K ).each do |rank|
        card = Card.new(suit: "hearts", rank: rank)
        expect(card.value).to eq(10)
      end
    end

    it "is 11 for A" do
      card = Card.new(suit: "diams", rank: "A")
      expect(card.value).to eq(11)
    end
  end
end
