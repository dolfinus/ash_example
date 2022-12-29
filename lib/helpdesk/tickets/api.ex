defmodule Helpdesk.Tickets.Api do
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
    debug? true
    show_raised_errors? true
  end

  resources do
    registry Helpdesk.Tickets.Registry
  end
end
