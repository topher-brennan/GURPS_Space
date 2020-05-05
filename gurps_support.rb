# frozen_string_literal: true

module GurpsSupport
  def n_d(n)
    roll = 0
    n.times { roll += (rand(6) + 1) }
    roll
  end
end
