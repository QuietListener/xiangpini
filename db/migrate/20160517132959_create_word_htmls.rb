class CreateWordHtmls < ActiveRecord::Migration
  def change
    create_table :word_htmls do |t|
      t.integer :word_id
      t.text :html_haici ,:limit => 4294967295
      t.integer :status_haici
      t.timestamps
    end
  end
end
