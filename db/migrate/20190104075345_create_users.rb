class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.integer :balance, :default => 0

      t.timestamps
    end
  end
end
