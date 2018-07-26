require 'yaml'
require 'remedy'
require_relative 'board'

class MinesweeperGame
  include Remedy

  LAYOUTS = {
    small: { grid_size: 9, num_bombs: 10 },
    medium: { grid_size: 16, num_bombs: 40 },
    large: { grid_size: 32, num_bombs: 160 }
  }.freeze.each { |k, v| v.freeze }

  def initialize(size)
    layout = LAYOUTS[size]
    @board = Board.new(layout[:grid_size], layout[:num_bombs])
    @size = layout[:grid_size]
  end

  def play
    until @board.won? || @board.lost?
      get_move
    end

    if @board.won?
      puts "You win!"
    elsif @board.lost?
      puts "**Bomb hit!**"
      puts @board.reveal
    end
  end

  private

  def get_move
    user_input = Interaction.new
    start_x = start_y = 0
    pos = [start_x, start_y]
    tile = @board[pos]
    tile.visit(pos)
    puts @board.render
    puts "Please move using your keyboard arrow keys. When you have the space you want selected, press an action key"
    puts "Action keys - e: explore, f: flag, s: save"
    user_input.loop do |key|
      system("clear")
      puts "Action keys - e: explore, f: flag, s: save"

      case key.to_s
      when "right"
        start_y += 1 unless start_y >= (@size - 1)
      when "left"
        start_y -= 1 unless start_y <= 0
      when "up"
        start_x -= 1 unless start_x <= 0
      when "down"
        start_x += 1 unless start_x >= (@size - 1)
      when "e"
        perform_move("e", pos)
      when "f"
        perform_move("f", pos)
      when "s"
        perform_move("s", pos)
      end
      if @board.lost? || @board.won?
        @board.reveal
        return
      end
      pos = [start_x, start_y]
      tile = @board[pos]
      tile.visit(pos)
      puts @board.render
    end
  end

  def perform_move(action_type, pos)
    tile = @board[pos]

    case action_type
    when "f"
      tile.toggle_flag
    when "e"
      tile.explore
    when "s"
      save
    end
  end

  def save
    puts "Enter filename to save at:"
    filename = gets.chomp

    File.write(filename, YAML.dump(self))
  end

end

if $PROGRAM_NAME == __FILE__
  case ARGV.count
  when 0
    MinesweeperGame.new(:small).play
  when 1
    YAML.load_file(ARGV.shift).play
  end
end
