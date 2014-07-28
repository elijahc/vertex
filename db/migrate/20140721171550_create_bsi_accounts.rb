class CreateBsiAccounts < ActiveRecord::Migration
  def change
    create_table :bsi_accounts do |t|
      t.string :username
      t.binary :password
      t.binary :anfangvektor
      t.boolean :verified

      t.timestamps
    end
  end
end
