class RemoveAverageRatingFromProperties < ActiveRecord::Migration[8.0]
  def change
    remove_column :properties, :average_rating, :float
  end
end
