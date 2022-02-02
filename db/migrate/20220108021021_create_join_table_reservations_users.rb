class CreateJoinTableReservationsUsers < ActiveRecord::Migration[5.0]
  def change
    create_join_table :reservations, :guests do |t|
      # t.index [:reservation_id, :guest_id]
      # t.index [:guest_id, :reservation_id]
    end
  end
end
