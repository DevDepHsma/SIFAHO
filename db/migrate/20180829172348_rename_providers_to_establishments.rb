class RenameProvidersToEstablishments < ActiveRecord::Migration[5.1]
  def change
    rename_table :providers, :establishments
  end
end
