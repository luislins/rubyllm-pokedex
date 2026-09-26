require "test_helper"

class Pokemon::GeneratorTest < ActiveSupport::TestCase
  # Stands in for RubyLLM::Chat: records the schema it was given and answers
  # with a canned structured response.
  class FakeChat
    Response = Struct.new(:parsed, :content)

    attr_reader :schema, :prompt

    def initialize(parsed)
      @parsed = parsed
    end

    def with_schema(schema)
      @schema = schema
      self
    end

    def ask(prompt)
      @prompt = prompt
      Response.new(@parsed, @parsed.to_json)
    end
  end

  test "builds an unsaved Pokemon from the structured response" do
    chat = FakeChat.new("name" => "Pikachu", "element_type" => "electric", "generation" => "gen1")

    pokemon = Pokemon::Generator.call("a small electric mouse", chat: chat)

    assert pokemon.new_record?
    assert_equal "Pikachu", pokemon.name
    assert pokemon.electric?
    assert pokemon.gen1?
  end

  test "sends the description with the Pokemon schema" do
    chat = FakeChat.new("name" => "Squirtle", "element_type" => "water", "generation" => "gen1")

    Pokemon::Generator.call("a tiny turtle", chat: chat)

    assert_equal PokemonSchema, chat.schema
    assert_equal "a tiny turtle", chat.prompt
  end

  test "ignores keys outside the schema" do
    chat = FakeChat.new("name" => "Eevee", "element_type" => "normal", "generation" => "gen1", "id" => 999)

    pokemon = Pokemon::Generator.call("a fluffy fox", chat: chat)

    assert_nil pokemon.id
  end

  test "rejects a blank description without asking the model" do
    chat = FakeChat.new({})

    assert_raises Pokemon::Generator::BlankDescription do
      Pokemon::Generator.call("   ", chat: chat)
    end
    assert_nil chat.prompt
  end
end
