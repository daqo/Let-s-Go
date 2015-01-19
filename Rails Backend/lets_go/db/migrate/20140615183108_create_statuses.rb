class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.references :user, index: true
      t.string :lat
      t.string :long
      t.string :body
      t.integer :duration
      t.string :image_url

      t.timestamps
    end
  end
end
