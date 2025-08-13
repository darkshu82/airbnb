class CreateWishlists < ActiveRecord::Migration[8.0]
  def change
    create_table :wishlists do |t|
      t.references :user, null: false, foreign_key: true
      t.references :property, null: false, foreign_key: true

      t.timestamps
    end

    # 하나의 유저가 같은 상품을 중복으로 찜하지 못하게
    add_index :wishlists, [ :user_id, :property_id ], unique: true
  end
end
