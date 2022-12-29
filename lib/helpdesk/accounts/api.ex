defmodule Helpdesk.Accounts.Api do
  use Ash.Api,
    extensions: [
      AshJsonApi.Api,
      AshGraphql.Api,
      AshAdmin.Api
    ]

  admin do
    show? true
  end

  graphql do
    authorize? true
  end

  resources do
    registry Helpdesk.Accounts.Registry
  end
end
