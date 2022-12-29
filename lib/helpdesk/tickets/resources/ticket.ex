defmodule Helpdesk.Tickets.Ticket do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [
      Ash.Policy.Authorizer
    ],
    notifiers: [
      Ash.Notifier.PubSub
    ],
    extensions: [
      AshGraphql.Resource
    ]

  pub_sub do
    # A prefix for all messages
    prefix "ticket"
    # The module to call `broadcast/3` on
    module HelpdeskWeb.Endpoint

    # When a ticket is assigned, publish ticket:assigned_to:<representative_id>
    publish :assign, ["assigned_to", :representative_id]
    publish_all(:update, ["updated", :representative_id])
    publish_all(:update, ["updated", :reporter_id])
  end

  graphql do
    type :ticket

    queries do
      get :get_ticket, :read
      list :list_tickets, :read, relay?: true
    end

    mutations do
      create :open_ticket, :open
      update :update_ticket, :update
      destroy :destroy_ticket, :destroy
    end
  end

  policies do
    bypass always() do
      authorize_if actor_attribute_equals(:admin, true)
    end

    policy action_type(:read) do
      authorize_if actor_attribute_equals(:representative, true)
      authorize_if relates_to_actor_via(:reporter)
    end

    policy changing_relationship(:reporter) do
      authorize_if relating_to_actor(:reporter)
    end
  end

  actions do
    read :reported do
      filter reporter: actor(:id)

      pagination offset?: true, countable: true, required?: false
    end

    read :assigned do
      filter representative: actor(:id)
      pagination offset?: true, countable: true, required?: false
    end

    read :read do
      primary? true
      pagination offset?: true, keyset?: true, required?: false
    end

    create :open do
      accept [:subject]
    end

    update :update, primary?: true

    update :assign

    destroy :destroy
  end

  postgres do
    table "tickets"
    repo Helpdesk.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :subject, :string do
      allow_nil? false
      constraints min_length: 5
    end

    attribute :description, :string

    attribute :response, :string

    attribute :status, :atom do
      allow_nil? false
      default "new"
      constraints one_of: [:new, :investigating, :closed]
    end

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :reporter, Helpdesk.Tickets.Customer

    belongs_to :representative, Helpdesk.Tickets.Representative
  end
end
