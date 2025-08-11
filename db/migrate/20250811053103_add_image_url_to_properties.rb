class AddImageUrlToProperties < ActiveRecord::Migration[8.0]
  def change
    add_column :properties, :image_url, :text
  end
end
