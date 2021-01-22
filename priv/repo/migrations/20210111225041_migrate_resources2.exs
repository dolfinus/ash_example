defmodule Helpdesk.Repo.Migrations.MigrateResources2 do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:users) do
      modify :admin, :boolean
    end

    drop_if_exists unique_index(:users, [:first_name, :last_name],
                     name: "users_representative_name_unique_index"
                   )

    create unique_index(:users, [:first_name, :last_name],
             name: "users_representative_name_unique_index",
             where: "representative = true"
           )

    drop constraint(:tickets, "tickets_representative_id_fkey")

    drop constraint(:tickets, "tickets_reporter_id_fkey")

    alter table(:tickets) do
      modify :subject, :text
      modify :status, :text, default: nil
      modify :response, :text
      modify :id, :binary_id
      modify :description, :text
      modify :reporter_id, references("users", type: :binary_id, column: :id)
    end

    alter table(:tickets) do
      modify :representative_id, references("users", type: :binary_id, column: :id)
    end
  end

  def down do
    drop constraint(:tickets, "tickets_representative_id_fkey")

    alter table(:tickets) do
      modify :representative_id, references("users", type: :binary_id, column: :id)
    end

    drop constraint(:tickets, "tickets_reporter_id_fkey")

    alter table(:tickets) do
      modify :reporter_id, references("users", type: :binary_id, column: :id)
      modify :description, :text
      modify :id, :binary_id
      modify :response, :text
      modify :status, :text, default: "new"
      modify :subject, :text
    end

    drop_if_exists unique_index(:users, [:first_name, :last_name],
                     name: "users_representative_name_unique_index"
                   )

    create unique_index(:users, [:first_name, :last_name],
             name: "users_representative_name_unique_index",
             where: "representative = true"
           )

    alter table(:users) do
      modify :admin, :boolean
    end
  end
end
