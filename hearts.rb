class Card
  include Comparable
  attr_reader :rank, :suit

  VALUES = { 'J' => 11, 'Q' => 12, 'K' => 13, 'A' => 14 }
  SUIT_VALUES = { 'c' => 0, 'd' => 13, 's' => 26, 'h' => 39 }

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def to_s
    "#{rank}#{suit}"
  end

  def value
    VALUES.fetch(rank, rank) + SUIT_VALUES.fetch(suit)
  end

  def <=>(other_card)
    value <=> other_card.value
  end
end

class Deck
  RANKS = ((2..10).to_a + %w(J Q K A)).freeze
  SUITS = %w(c h s d).freeze

  def initialize
    reset
  end

  def deal
    @deck.pop
  end

  def reset
    @deck = RANKS.product(SUITS).map do |rank, suit|
      Card.new(rank, suit)
    end

    @deck.shuffle!
  end
end

class Player
  attr_reader :name, :cards, :position, :points_for_round
  attr_accessor :turn, :chosen_card, :collected_cards, :score, :pass_cards

  def initialize
    reset
  end

  def reset
    @cards = []
    @collected_cards = []
    @pass_cards = []
    @turn = false
    @chosen_card = nil
    @score = 0
  end

  def play_card
    @cards.delete(chosen_card)
  end

  def hearts
    collected_cards.count { |card| card.suit == 'h' }
  end

  def queen_of_spades
    collected_cards.any? { |card| card.to_s == 'Qs' } ? 13 : 0
  end

  def calculate_points
    @score += (hearts + queen_of_spades)
  end

  def two_of_clubs?
    twoclub = cards.select { |card| card.to_s == '2c' }
    !twoclub.empty?
  end

  def right_position
    right_pos = position - 1
    right_pos += 4 if right_pos < 1
    right_pos
  end

  def across_position
    across_pos = position + 2
    across_pos -= 4 if across_pos > 4
    across_pos
  end

  def left_position
    left_pos = position + 1
    left_pos -= 4 if left_pos > 4
    left_pos
  end
end

class Human < Player
  def initialize
    @name = input_name
    @position = 1
    super
  end

  def select_card
    display_cards
    @chosen_card = pick_card(play_message)
  end

  def display_cards
    puts cards.sort.join(', ')
  end

  def cards_to_pass
    3.times do
      display_cards
      @pass_cards << cards.delete(pick_card(pass_message))
    end
  end

  private

  def input_name
    input = nil
    loop do
      puts 'Please enter you name:'
      input = gets.chomp
      break unless input.empty?
      puts 'You must enter a valid name.'
    end

    input
  end

  def pick_card(message)
    selected_card = nil
    loop do
      puts message
      card_input = gets.chomp.downcase
      selected_card = cards.select { |card| card_input == card.to_s.downcase }
      break unless selected_card.empty?
      puts "You don't have that card"
    end
    selected_card[0]
  end

  def pass_message
    "Choose a card to pass"
  end

  def play_message
    "Choose a card to play"
  end
end

class Computer < Player
  def select_card
    @chosen_card = cards.sample
  end

  def cards_to_pass
    3.times do
      @pass_cards << cards.delete(cards.sample)
    end
  end
end

class LeBron < Computer
  def initialize
    @name = 'LeBron'
    @position = 2
    super
  end
end

class Michael < Computer
  def initialize
    @name = 'Michael'
    @position = 3
    super
  end
end

class Magic < Computer
  def initialize
    @name = 'Magic'
    @position = 4
    super
  end
end

class Table
  attr_accessor :played_cards, :suit, :hearts_broken, :players

  SUIT_NAMES = {
    'c' => 'Clubs',
    'h' => 'Hearts',
    's' => 'Spades',
    'd' => 'Diamonds'
  }

  def initialize
    clear
    reset_hearts
  end

  def clear
    @played_cards = []
  end

  def reset_hearts
    @hearts_broken = false
  end

  def suit
    !played_cards.empty? ? played_cards.first.suit : nil
  end

  def display
    system "clear"
    top_third
    middle_third
    botton_third
  end

  def table_suit
    puts " " * 8 + "|" + "Chosen suit: #{chosen_suit}".center(30) + "|"
  end

  def import_players(players)
    @players = players
  end

  private

  def top_third
    player_three
    long_edge
    table_suit
    side_edge
  end

  def middle_third
    seat_three
    side_edge
    seats_two_and_four
    side_edge
    seat_one
  end

  def botton_third
    side_edge
    side_edge
    long_edge
    player_name
  end

  def long_edge
    puts " " * 8 + "+" + "-" * 30 + "+"
  end

  def side_edge
    puts " " * 8 + "|" + " " * 30 + "|"
  end

  def seat_three
    puts " " * 8 + "|" + players[2].chosen_card.to_s.center(30) + "|"
  end

  def seats_two_and_four
    puts " LeBron " + "|" + players[1].chosen_card.to_s.center(15) +
         players[3].chosen_card.to_s.center(15) + "| Magic"
  end

  def seat_one
    puts " " * 8 + "|" + players[0].chosen_card.to_s.center(30) + "|"
  end

  def chosen_suit
    SUIT_NAMES[suit]
  end

  def player_three
    puts " " * 8 + "Michael".center(32)
  end

  def player_name
    puts " " * 8 + players[0].name.to_s.center(32)
    blank_line
  end

  def blank_line
    puts ""
  end
end

class Scoreboard
  attr_accessor :scores, :totals

  def initialize
    @scores = {}
    @totals = Array.new(4, 0)
    @players = nil
  end

  def import_players(players)
    @players = players
  end

  def calculate_totals
    latest_scores = @scores.max_by { |rnd, _| rnd }[1]
    @totals = [@totals, latest_scores].transpose.map { |x| x.reduce(:+) }
  end

  def display
    name_banner
    round_scores
    total_scores
  end

  def winning_index
    @totals.find_index(@totals.min)
  end

  private

  def name_banner
    puts horizontal_line
    puts "|       |" + @players[0].name.to_s.center(10) +
         "|  LeBron  |  Micahel |  Magic   |"
    puts horizontal_line
  end

  def horizontal_line
    "+-------+" + "----------+" * 4
  end

  def round_scores
    i = 1
    @scores.size.times do
      puts round_number(i) +
           player_x_score(1, i) +
           player_x_score(2, i) +
           player_x_score(3, i) +
           player_x_score(4, i)
      puts bottom_line
      i += 1
    end
  end

  def player_x_score(pos, i)
    @scores[i][pos - 1].to_s.center(10).to_s + "|"
  end

  def player_x_total(pos)
    @totals[pos - 1].to_s.center(10).to_s + "|"
  end

  def round_number(i)
    "| #{i.to_s.center(5)} |"
  end

  def total_box
    "| Total |"
  end

  def total_scores
    puts total_box +
         player_x_total(1) +
         player_x_total(2) +
         player_x_total(3) +
         player_x_total(4)
    puts bottom_line
  end

  def bottom_line
    "+-------+" + "----------+" * 4
  end
end

class Hearts
  attr_accessor :round
  attr_reader :players

  GAME_ENDING_SCORE = 100

  def initialize
    puts "Welcome to Hearts!"
    initialize_players
    @deck = Deck.new
    @table = Table.new
    @table.import_players(@players)
    @scoreboard = Scoreboard.new
    @scoreboard.import_players(@players)
    @round = 0
  end

  def play
    loop do
      full_round
      display_winner
      break unless play_again?
    end
    thanks_for_playing
  end

  private

  def initialize_players
    @human = Human.new
    @michael = Michael.new
    @magic = Magic.new
    @lebron = LeBron.new
    @players = [@human, @lebron, @michael, @magic]
  end

  def deal
    13.times do
      @human.cards << @deck.deal
      @michael.cards << @deck.deal
      @magic.cards << @deck.deal
      @lebron.cards << @deck.deal
    end
  end

  def current_player
    players.each { |player| return player if player.turn }
  end

  def valid_card?(picked_card)
    valid_cards = nil
    if current_player.two_of_clubs?
      valid_cards = must_play_two_clubs
    elsif hearts_not_broken
      valid_cards = all_cards_except_hearts
    else
      valid_cards = follow_suit_cards
    end
    valid_cards.empty? || valid_cards.include?(picked_card)
  end

  def hearts_not_broken
    @table.hearts_broken == false && @table.suit.nil?
  end

  def must_play_two_clubs
    current_player.cards.select { |card| card.to_s == '2c' }
  end

  def all_cards_except_hearts
    current_player.cards.select { |card| card.suit != 'h' }
  end

  def follow_suit_cards
    current_player.cards.select { |card| card.suit == @table.suit }
  end

  def two_of_clubs
    players.each do |player|
      return player if player.cards.any? { |card| card.to_s == '2c' }
    end
  end

  def starts_round?
    players.each { |player| player.turn = player == two_of_clubs }
  end

  def next_position
    next_pos = current_player.position + 1
    next_pos -= 4 if next_pos > 4
    players.each do |player|
      player.position == next_pos ? player.turn = true : player.turn = false
    end
  end

  def set_table_suit
    @table.suit = @table.played_cards.first.suit if !@table.played_cards.empty?
  end

  def play_hand
    @table.display
    4.times do
      place_cards
      @table.played_cards << current_player.play_card
      next_position
      hearts_broken?
      @table.display
    end
  end

  def place_cards
    loop do
      set_table_suit
      break if valid_card?(current_player.select_card)
    end
  end

  def hearts_broken?
    @table.hearts_broken = true if hearts_played?
  end

  def hearts_played?
    @table.played_cards.any? { |card| card.suit == 'h' }
  end

  def winning_card
    @table.played_cards.select { |card| card.suit == @table.suit }.sort.last
  end

  def won_hand?
    players.each { |plyr| return plyr if plyr.chosen_card == winning_card }
  end

  def won_hand_message
    puts "#{won_hand?.name} won the hand"
    sleep 2
  end

  def collect_cards
    won_hand?.collected_cards.concat(@table.played_cards)
  end

  def starts_hand
    players.each { |player| player.turn = player.chosen_card == winning_card }
  end

  def moon_shot?
    @scoreboard.scores[round].include?(26)
  end

  def shot_the_moon_points_update
    @scoreboard.scores[round].map! { |scr| scr == 26 ? 0 : 26 } if moon_shot?
  end

  def update_scores
    @scoreboard.scores[round] = []
    players.each do |player|
      @scoreboard.scores[round] << player.calculate_points
      shot_the_moon_points_update
      player.score = 0
    end
    @scoreboard.calculate_totals
  end

  def clear_hands
    players.each { |player| player.chosen_card = nil }
  end

  def play_round
    starts_round?
    13.times do
      clear_hands
      play_hand
      collect_cards
      won_hand_message
      starts_hand
      @table.clear
    end
    @table.reset_hearts
  end

  def select_pass_cards
    players.each(&:cards_to_pass)
  end

  def pass_cards
    if @round % 3 == 0
      pass_cards_across
    elsif @round.even?
      pass_cards_right
    else
      pass_cards_left
    end
  end

  def pass_cards_right
    players.each do |player|
      players.each do |opponent|
        if opponent.position == player.right_position
          opponent.cards << player.pass_cards
        end
        opponent.cards.flatten!
      end
      player.pass_cards = []
    end
  end

  def pass_cards_left
    players.each do |player|
      players.each do |opponent|
        if opponent.position == player.left_position
          opponent.cards << player.pass_cards
        end
        opponent.cards.flatten!
      end
      player.pass_cards = []
    end
  end

  def pass_cards_across
    players.each do |player|
      players.each do |opponent|
        if opponent.position == player.across_position
          opponent.cards << player.pass_cards
        end
        opponent.cards.flatten!
      end
      player.pass_cards = []
    end
  end

  def game_over?
    @scoreboard.totals.any? { |x| x >= GAME_ENDING_SCORE }
  end

  def display_winner
    puts "#{players[@scoreboard.winning_index].name} won!"
  end

  def thanks_for_playing
    puts "Thanks for playing Hearts. Good Bye!"
  end

  def next_game
    puts "Press any key to continue"
    gets
    system "clear"
  end

  def return_cards
    players.each(&:reset)
  end

  def play_again?
    puts "Would you like to play again?(y/n)"
    answer = gets.chomp.downcase
    answer.start_with?('y')
  end

  def select_and_pass_cards
    return if @round % 4 == 0
    select_pass_cards
    pass_cards
  end

  def prepare_round
    return_cards
    @deck.reset
    @round += 1
    deal
  end

  def update_and_display_score
    update_scores
    @scoreboard.display
  end

  def full_round
    loop do
      prepare_round
      select_and_pass_cards
      play_round
      update_and_display_score
      break if game_over?
      next_game
    end
  end
end

game = Hearts.new
game.play
