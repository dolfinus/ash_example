defmodule Helpdesk.Accounts.User do
  # lib/helpdesk/accounts/resources/user.ex
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [
      AshPolicyAuthorizer.Authorizer
    ],
    extensions: [
      AshJsonApi.Resource,
      AshGraphql.Resource
    ]

  graphql do
    type(:user)

    fields([:first_name, :last_name, :representative, :admin])

    queries do
      get(:get_user, :me)
    end

    mutations do
      create(:create_user, :create)
      update(:update_user, :update)
      destroy(:destroy_user, :destroy)
    end
  end

  json_api do
    type("user")

    routes do
      base("/users")

      get(:me, route: "/me")
      index(:read)
      post(:create)
      patch(:update)
      delete(:destroy)
    end

    fields([:first_name, :last_name, :representative, :admin])
  end

  policies do
    bypass always() do
      authorize_if(actor_attribute_equals(:admin, true))
    end

    policy action_type(:read) do
      authorize_if(attribute(:id, eq: actor(:id)))
    end
  end

  actions do
    read(:me, filter: [id: actor(:id)])
    read(:read, primary?: true)
    create(:create)
    update(:update)
    destroy(:destroy)
  end

  postgres do
    table("users")
    repo(Helpdesk.Repo)
  end

  validations do
    validate(present([:first_name, :last_name], at_least: 1))
  end

  attributes do
    attribute :id, :uuid do
      primary_key?(true)
      default(&Ecto.UUID.generate/0)
    end

    attribute :first_name, :string do
      constraints(min_length: 1)
    end

    attribute :last_name, :string do
      constraints(min_length: 1)
    end

    attribute :representative, :boolean do
      allow_nil?(false)
      default(false)
    end

    attribute :admin, :boolean do
      allow_nil?(false)
      default(false)
    end
  end
end
