# RubyLLM Pokédex

[![CI](https://github.com/luislins/rubyllm-pokedex/actions/workflows/ci.yml/badge.svg)](https://github.com/luislins/rubyllm-pokedex/actions/workflows/ci.yml)

A small Rails app that turns a free-text description into a Pokémon record
using structured output from an LLM. Rails 8.1, RubyLLM 2.0, SQLite. A
scaffolded CRUD plus one AI-powered form.

## Features

- Describe a Pokémon in plain text and get a saved record with name, element
  type and generation
- The model can only answer with values the database accepts: the JSON schema's
  enums are built from the `Pokemon` model's own enums
- Regular CRUD for hand-made Pokémon
- RubyLLM's Rails integration installed (chats, messages, tool calls, usage
  ledger), ready for persisted conversations

## Stack

| | |
|---|---|
| Backend | Ruby 3.4.2, Rails 8.1 |
| LLM | [RubyLLM](https://rubyllm.com) 2.0, OpenAI provider by default |
| Structured output | `chat.with_schema` + a [Schematist](https://github.com/crmne/schematist) schema class |
| Database | SQLite, with Solid Queue / Cache / Cable |
| Frontend | Hotwire (Turbo, Stimulus) via importmap |
| Tests | Minitest, system tests with Selenium |
| Deploy | Kamal (Dockerfile included) |

## Technical decisions

**Structured output instead of parsing prose.** The request goes out with a
JSON schema (`app/schemas/pokemon_schema.rb`) and the answer comes back as a
hash that already matches the `pokemons` columns. No regexes, no "please
answer in JSON" prompt engineering.

**The schema is derived from the model.** `enum: Pokemon.element_types.keys`
and `enum: Pokemon.generations.keys` mean the model cannot invent a type or a
generation that the database would reject. Add a value to the enum in the
model and the schema follows.

**`response.parsed` straight into `Pokemon.new`.** The schema's keys are the
column names, so there is no mapping layer. If the provider returns something
the model rejects, the form re-renders with the validation errors.

**The AI form is stateless.** `RubyLLM.chat` builds a plain Ruby chat for each
request; nothing is persisted. The `Chat` and `Message` models and the
`ruby_llm_*` tables come from the RubyLLM install generator and are there for
when conversation history matters.

**Provider configuration through the environment.** `OPENAI_API_KEY` is read
in `config/initializers/ruby_llm.rb`; dotenv loads `.env` in development and
test. Swap the provider or the default model in that initializer.

**Scaffold on purpose.** The CRUD is the Rails generator's output, lightly
edited. The interesting part is the one action that talks to the LLM.

## Running it

Requires Ruby 3.4.2 and an OpenAI API key.

```bash
bundle install
bin/rails db:prepare
echo "OPENAI_API_KEY=sk-..." > .env

bin/dev
```

Open http://localhost:3000/pokemons/new_with_ai, describe a Pokémon ("a small
electric mouse from the first generation") and submit.

The model used is RubyLLM's default for the OpenAI provider. To pin one, set
`config.default_model` in `config/initializers/ruby_llm.rb`.

## Tests

```bash
bin/rails test
bin/rails test:system   # needs Chrome
```

The test suite does not call the OpenAI API.

## Layout

```
app/
├── controllers/
│   └── pokemons_controller.rb     CRUD + new_with_ai / create_with_ai
├── models/
│   ├── pokemon.rb                 enums for element_type and generation
│   ├── chat.rb                    acts_as_chat (RubyLLM)
│   └── message.rb                 acts_as_message (RubyLLM)
├── schemas/
│   └── pokemon_schema.rb          JSON schema sent with the request
└── views/pokemons/
    └── new_with_ai.erb            the description form
config/initializers/ruby_llm.rb    provider keys and default model
```

## License

MIT, see [LICENSE](LICENSE).
