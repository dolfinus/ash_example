defmodule Helpdesk.Tickets.Customer do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [
      Ash.Policy.Authorizer
    ],
    extensions: [
      AshGraphql.Resource
    ]

  resource do
    base_filter representative: false
  end

  multitenancy do
    strategy :context
  end

  graphql do
    type :customer
  end

  postgres do
    table "users"
    repo Helpdesk.Repo
  end

  policies do
    bypass always() do
      authorize_if actor_attribute_equals(:admin, true)
    end

    policy action_type(:read) do
      authorize_if attribute(:id, not: [eq: actor(:id)])
      authorize_if relates_to_actor_via([:reported_tickets, :representative])
    end
  end

  actions do
    read :read do
      primary? true
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :first_name, :string
    attribute :last_name, :string
    attribute :representative, :boolean
  end

  relationships do
    has_many :reported_tickets, Helpdesk.Tickets.Ticket do
      destination_attribute :reporter_id
    end
  end
end
