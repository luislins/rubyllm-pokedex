require "test_helper"
require "minitest/mock"

class PokemonsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pokemon = pokemons(:one)
  end

  test "should get index" do
    get pokemons_url
    assert_response :success
  end

  test "should get new" do
    get new_pokemon_url
    assert_response :success
  end

  test "should create pokemon" do
    assert_difference("Pokemon.count") do
      post pokemons_url, params: { pokemon: { name: "Pikachu", element_type: "electric", generation: "gen1" } }
    end

    assert_redirected_to pokemon_url(Pokemon.last)
  end

  test "should not create pokemon without a name" do
    assert_no_difference("Pokemon.count") do
      post pokemons_url, params: { pokemon: { element_type: "electric" } }
    end

    assert_response :unprocessable_entity
  end

  test "should get new_with_ai" do
    get new_with_ai_pokemons_url
    assert_response :success
  end

  test "should create pokemon with ai" do
    generated = Pokemon.new(name: "Pikachu", element_type: "electric", generation: "gen1")

    Pokemon::Generator.stub :call, generated do
      assert_difference("Pokemon.count") do
        post create_with_ai_pokemons_url, params: { pokemon_description: "a small electric mouse" }
      end
    end

    assert_redirected_to pokemon_url(Pokemon.last)
    assert_equal "Pikachu was created from your description.", flash[:notice]
  end

  test "should re-render the form when the description is blank" do
    assert_no_difference("Pokemon.count") do
      post create_with_ai_pokemons_url, params: { pokemon_description: "" }
    end

    assert_response :unprocessable_entity
    assert_match "Describe the Pokemon first", response.body
  end

  test "should re-render the form when the provider fails" do
    failure = ->(*) { raise RubyLLM::Error, "provider is down" }

    Pokemon::Generator.stub :call, failure do
      assert_no_difference("Pokemon.count") do
        post create_with_ai_pokemons_url, params: { pokemon_description: "a small electric mouse" }
      end
    end

    assert_response :unprocessable_entity
    assert_match "provider is down", response.body
  end

  test "should show pokemon" do
    get pokemon_url(@pokemon)
    assert_response :success
  end

  test "should get edit" do
    get edit_pokemon_url(@pokemon)
    assert_response :success
  end

  test "should update pokemon" do
    patch pokemon_url(@pokemon), params: { pokemon: {} }
    assert_redirected_to pokemon_url(@pokemon)
  end

  test "should destroy pokemon" do
    assert_difference("Pokemon.count", -1) do
      delete pokemon_url(@pokemon)
    end

    assert_redirected_to pokemons_url
  end
end
