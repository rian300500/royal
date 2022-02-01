# frozen_string_literal: true

class User < ActiveRecord::Base
  include Royal::Points

  def self.create_table
    connection.create_table(:users, if_not_exists: true) do |t|
      t.string :username
      t.timestamps
    end
  end
end
