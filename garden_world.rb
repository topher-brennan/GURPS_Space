# frozen_string_literal: true

require_relative 'gurps_support'

class GardenWorld
  include GurpsSupport

  def initialize
    @size = roll_size
    @atmospheric_mass = n_d(3) / 10.0 - 0.05 + rand/10
    @marginal = n_d(3) > 11
    @hydrographics = roll_hydrographics
    @surface_temp = roll_surface_temp
    @absorption = roll_absorption
    @blackbody = roll_blackbody
    @blackbody_temp = @surface_temp / blackbody_correction
    @density = roll_density
    @gravity = roll_gravity
    @resources = roll_resources
  end

  def roll_size
    n_d(3) < 17 ? :standard : :large
  end

  def roll_hydrographics
    result = n_d(1) * 0.1 + 0.35 + rand/10
    result += 0.2 if @size == :large
    [result, 1].min
  end

  def roll_surface_temp
    (n_d(3) - 3.5 + rand) * 6 + 250
  end

  def roll_absorption
    case @hydrographics
    when (0..0.2)
      return 0.9 + rand/10
    when (0.2..0.5)
      return 0.87 + rand/10
    when (0.5..0.9)
      return 0.83 + rand/10
    else
      return 0.79 + rand/10
    end
  end

  def roll_blackbody
    0.11 + rand/10
  end

  def blackbody_correction
    @absorption * (1 + @atmospheric_mass * @blackbody)
  end

  def roll_density
    case n_d(3)
    when (3..6)
      return 0.75 + rand/10
    when (7..10)
      return 0.85 + rand/10
    when (11..14)
      return 0.95 + rand/10
    when (15..17)
      return 1.05 + rand/10
    else
      return 1.15 + rand/10
    end
  end

  def roll_gravity
    roll = n_d(2) - 2.5 + rand
    factor = Math.sqrt(@blackbody_temp * @density)
    if @size == :standard
      return (0.03 + roll * 0.0035) * factor
    else
      return (0.065 + roll * 0.0026) * factor
    end
  end

  def atmospheric_pressure
    result = @atmospheric_mass * @gravity
    result *= 5 if @size == :large
    result
  end
  
  def roll_resources
    case n_d(3)
    when (3..4)
      return -2
    when (5..7)
      return -1
    when (8..13)
      return 0
    when (14..16)
      return 1
    else
      return 2
    end
  end
  
  def habitability
    result = 0

    case atmospheric_pressure
    when (0.01..0.5)
      result += 1
    when (0.5..0.8)
      result += 2
    when (0.8..1.5)
      result += 3
    else (1.5..Float::INFINITY)
      result += 1
    end

    result += 1 if !@marginal

    case @hydrographics
    when (0...0.6)
      result += 1
    when (0.6...0.9)
      result += 2
    when (0.9...1)
      result += 1
    end

    case @surface_temp
    when (255...266)
      result += 1
    when (266...322)
      result += 2
    when (322...333)
      result += 1
    end

    result
  end 

  def output_statistics
    puts "Size: #{@size.to_s.capitalize}"
    puts "Atmospheric Mass: #{@atmospheric_mass.round(2)}"
    puts "Marginal Atmosphere?: #{@marginal}"
    puts "Hydrographic Coverage: #{@hydrographics.round(2)}"
    puts "Surface Temperature: #{@surface_temp.round}"
    puts "Blackbody Temperature: #{@blackbody_temp.round}"
    puts "Surface Gravity: #{@gravity.round(2)}"
    puts "Atmospheric Pressure: #{atmospheric_pressure.round(2)}"
    puts "Resources: #{@resources}"
    puts "Habitability: #{habitability}"
  end
end

if $PROGRAM_NAME == __FILE__
  GardenWorld.new.output_statistics
end
