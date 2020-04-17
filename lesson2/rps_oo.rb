require 'pry'

class Move
  attr_accessor :beats, :loses, :value

  def initialize(value)
    @value = value
  end

  def >(other_move)
    @beats.include?(other_move.value)
  end

  def <(other_move)
    @loses.include?(other_move.value)
  end

  def to_s
    @value
  end
end

class Paper < Move
  def initialize
    @value = 'paper'
    @beats = ['rock', 'spock']
    @loses = ['scissors', 'lizard']
  end
end

class Rock < Move
  def initialize
    @value = 'rock'
    @beats = ['lizard', 'scissors']
    @loses = ['paper', 'spock']
  end
end

class Scissors < Move
  def initialize
    @value = 'scissors'
    @beats = ['lizard', 'paper']
    @loses = ['rock', 'spock']
  end
end

class Spock < Move
  def initialize
    @value = 'spock'
    @beats = ['rock', 'scissors']
    @loses = ['paper', 'lizard']
  end
end

class Lizard < Move
  def initialize
    @value = 'lizard'
    @beats = ['spock', 'paper']
    @loses = ['rock', 'scissors']
  end
end

class Player
  attr_accessor :move, :name, :score, :beats, :loses, :history, :value

  VALUES = {
    'rock' => Rock.new,
    'paper' => Paper.new,
    'scissors' => Scissors.new,
    'spock' => Spock.new,
    'lizard' => Lizard.new
  }

  def initialize
    set_name
    @score = 0
    @history = []
  end
end

class Human < Player
  def set_name
    n = ''
    loop do
      puts "What's your name?"
      n = gets.chomp.capitalize
      break unless n.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, scissors, lizard or spock:"
      choice = gets.chomp
      break if Player::VALUES.keys.include?(choice)
      puts "Sorry, invalid choice."
    end
    self.move = VALUES[choice]
  end
end

class Mario < Player
  def set_name
    self.name = 'Mario'
  end

  def choose
    self.move = VALUES[['rock', 'paper', 'scissors'].sample]
  end
end

class Link < Player
  def set_name
    self.name = 'Link'
  end

  def choose
    self.move = VALUES[['lizard', 'spock', 'lizard'].sample]
  end
end

class DonkeyKong < Player
  def set_name
    self.name = 'Donkey Kong'
  end

  def choose
    self.move = VALUES['rock']
  end
end

class Luigi < Player
  def set_name
    self.name = 'Luigi'
  end

  def choose
    self.move = VALUES[['spock', 'spock', 'spock', 'paper'].sample]
  end
end

class Zelda < Player
  def set_name
    self.name = 'Zelda'
  end

  def choose
    self.move = VALUES[['rock', 'paper', 'scissors', 'lizard', 'spock'].sample]
  end
end

class RPSGame
  attr_accessor :human, :computer

  WINNING_SCORE = 10
  COMPUTER_PLAYERS = [Zelda.new, Luigi.new, DonkeyKong.new, Link.new, Mario.new]

  def initialize
    @human = Human.new
    @computer = COMPUTER_PLAYERS.sample
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, Lizard, Spock!" \
          " First to #{WINNING_SCORE} wins!"
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors, Lizard, Spock. Good Bye!"
  end

  def display_moves
    puts "#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."
  end

  def display_winner
    if human.move > computer.move
      puts "#{human.name} won!"
    elsif human.move < computer.move
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
  end

  def update_score
    if human.move > computer.move
      human.score += 1
    elsif human.move < computer.move
      computer.score += 1
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include?(answer)
      puts "Sorry, must be y or n."
    end

    answer == 'y'
  end

  def display_score
    puts "#{human.name} #{human.score}:#{computer.score} #{computer.name}"
  end

  def reset_score
    human.score = 0
    computer.score = 0
  end

  def winning_player
    if human.score == WINNING_SCORE
      "#{human.name} is the winner!"
    else
      "#{computer.name} is the winner!"
    end
  end

  def display_final_result
    puts "Final score: #{human.name} #{human.score}:" \
    "#{computer.score} #{computer.name}"
    puts winning_player
  end

  def winner?
    human.score == WINNING_SCORE ||
      computer.score == WINNING_SCORE
  end

  def update_history
    human.history << human.move
    computer.history << computer.move
  end

  def want_history?
    answer = nil
    loop do
      puts "Would you like to see the move history? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include?(answer)
      puts "Sorry, must be y or n."
    end

    answer == 'y'
  end

  def display_history
    puts "Your moves were: #{human.history.join(', ')}."
    puts "#{computer.name}'s moves were: #{computer.history.join(', ')}."
  end

  def reset_history
    human.history = []
    computer.history = []
  end

  def display_opponet
    puts "Your opponent is #{computer.name}! Good luck!"
  end

  def play
    display_welcome_message
    display_opponet

    loop do
      reset_score
      reset_history

      loop do
        human.choose
        computer.choose
        # binding.pry
        display_moves
        display_winner
        update_score
        display_score
        update_history
        break if winner?
      end

      display_final_result
      display_history if want_history?
      break unless play_again?
    end

    display_goodbye_message
  end
end

RPSGame.new.play
