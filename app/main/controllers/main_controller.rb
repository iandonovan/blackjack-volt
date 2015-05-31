# By default Volt generates this controller for your Main component
module Main
  class MainController < Volt::ModelController
    def index
      player = Player.new(wins: 0, losses: 0)
      page._game = Game.new(player: player).fresh_game
    end

    def hit
      page._game.deal_card_to(page._game.player.cards)
    end

    def total(hand)
      page._game.total(hand)
    end

    def computer_turn
      page._game.computer_turn
    end

    def reset_game
      page._game.fresh_game
    end

    private

    # The main template contains a #template binding that shows another
    # template.  This is the path to that template.  It may change based
    # on the params._component, params._controller, and params._action values.
    def main_path
      "#{params._component || 'main'}/#{params._controller || 'main'}/#{params._action || 'index'}"
    end

    # Determine if the current nav component is the active one by looking
    # at the first part of the url against the href attribute.
    def active_tab?
      url.path.split('/')[1] == attrs.href.split('/')[1]
    end
  end
end
