# Turns a free-text description into an unsaved Pokemon by asking the model
# for a response that follows PokemonSchema.
#
#   Pokemon::Generator.call("a small electric mouse from the first games")
#   # => #<Pokemon name: "Pikachu", element_type: "electric", generation: "gen1">
#
# The chat can be injected, which is how the tests avoid the network.
class Pokemon::Generator
  class BlankDescription < StandardError
    def initialize(message = "Describe the Pokemon first.") = super
  end

  ATTRIBUTES = %w[name element_type generation].freeze

  def self.call(description, chat: nil)
    new(chat).call(description)
  end

  def initialize(chat = nil)
    @chat = chat
  end

  def call(description)
    raise BlankDescription if description.blank?

    response = chat.with_schema(PokemonSchema).ask(description)

    Pokemon.new(response.parsed.slice(*ATTRIBUTES))
  end

  private
    # Built lazily so a blank description never touches the provider.
    def chat
      @chat ||= RubyLLM.chat
    end
end
