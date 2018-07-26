require 'colorize'

class Tile
  DELTAS = [
    [-1, -1],
    [-1,  0],
    [-1,  1],
    [ 0, -1],
    [ 0,  1],
    [ 1, -1],
    [ 1,  0],
    [ 1,  1]
  ].freeze.each(&:freeze)

  attr_reader :pos
  attr_accessor :visited

  def initialize(board, pos)
    @board, @pos = board, pos
    @bombed, @explored, @flagged, @visited = false, false, false, false
  end

  def bombed?
    @bombed
  end

  def explored?
    @explored
  end

  def flagged?
    @flagged
  end

  def visited?
    @visited
  end

  def adjacent_bomb_count
    neighbors.select(&:bombed?).count
  end

  def explore
    # don't explore a location user thinks is bombed.
    return self if flagged?

    # don't revisit previously explored tiles
    return self if explored?

    @explored = true
    if !bombed? && adjacent_bomb_count == 0
      neighbors.each(&:explore)
    end

    self
  end

  def visit(pos)
    @board.grid.flatten.each { |tile| tile.visited = false }
    @visited = true
  end

  def inspect
    { pos: pos,
      bombed: bombed?,
      flagged: flagged?,
      explored: explored? }.inspect
  end

  def neighbors
    adjacent_coords = DELTAS.map do |(dx, dy)|
      [pos[0] + dx, pos[1] + dy]
    end.select do |row, col|
      [row, col].all? do |coord|
        coord.between?(0, @board.grid_size - 1)
      end
    end

    adjacent_coords.map { |pos| @board[pos] }
  end

  def plant_bomb
    @bombed = true
  end

  def color
    case adjacent_bomb_count
    when 1 then :blue
    when 2 then :red
    when 3 then :green
    end
  end

  def render
    if flagged? && visited?
      "F".colorize(:green)
    elsif flagged?
      "F"
    elsif explored? && visited?
      adjacent_bomb_count == 0 ? "_".colorize(:green) : adjacent_bomb_count.to_s.colorize(:green)
    elsif explored?
      adjacent_bomb_count == 0 ? "_" : adjacent_bomb_count.to_s.colorize(color)
    elsif visited?
      "*".colorize(:green)
    else
      "*"
    end
  end

  def reveal
    # used to fully reveal the board at game end
    if flagged?
      # mark true and false flags
      bombed? ? "F" : "f"
    elsif bombed?
      # display a hit bomb as an X
      explored? ? "X".colorize(:red) : "B".colorize(:red)
    else
      adjacent_bomb_count == 0 ? "_" : adjacent_bomb_count.to_s
    end
  end

  def toggle_flag
    @flagged = !@flagged unless @explored
  end
end
