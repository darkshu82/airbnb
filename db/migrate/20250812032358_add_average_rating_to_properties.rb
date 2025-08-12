class AddAverageRatingToProperties < ActiveRecord::Migration[8.0]
  def change
    add_column :properties, :average_rating, :float
  end
end
