require "ruby_llm/schema"

class PokemonSchema < RubyLLM::Schema
  description "This schema is used to create Pokemon. A Pokemon is a creature with a name, generation, and element type."

  string :name, description: "The name of the Pokemon"
  string :generation, enum: Pokemon.generations.keys, description: "The generation the Pokemon belongs to"
  string :element_type, enum: Pokemon.element_types.keys, description: "The elemental type of the Pokemon (e.g. fire, water, grass)"
end
