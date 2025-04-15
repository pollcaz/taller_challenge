class CreateReservations < ActiveRecord::Migration[7.2]
  def change
    create_table :reservations do |t|
      t.string :user_email, null: false
      t.references :book, null: false, foreign_key: true

      t.timestamps
    end
  end
end
