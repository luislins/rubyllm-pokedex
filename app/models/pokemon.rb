class Pokemon < ApplicationRecord
  validates :name, presence: true

  enum :element_type, {
    normal: 0,
    fire: 1,
    water: 2,
    electric: 3,
    grass: 4,
    ice: 5
  }

  enum :generation, {
    gen1: 1,
    gen2: 2,
    gen3: 3,
    gen4: 4,
    gen5: 5,
    gen6: 6
  }
end
