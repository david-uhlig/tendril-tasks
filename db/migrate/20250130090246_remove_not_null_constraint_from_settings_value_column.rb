class RemoveNotNullConstraintFromSettingsValueColumn < ActiveRecord::Migration[8.0]
  def change
    change_column_null :settings, :value, true
  end
end
