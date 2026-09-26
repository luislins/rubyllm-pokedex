# JSON schema the model must follow when it invents a Pokemon.
# The enums come straight from the Pokemon model, so the response can only
# contain values the database accepts.
class PokemonSchema < Schematist::Schema
  description "A Pokemon: a creature with a name, a generation and an element type."

  string :name, description: "The name of the Pokemon"
  string :generation, enum: Pokemon.generations.keys, description: "The generation the Pokemon belongs to"
  string :element_type, enum: Pokemon.element_types.keys, description: "The elemental type of the Pokemon (e.g. fire, water, grass)"
end
