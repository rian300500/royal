# frozen_string_literal: true

class User < ActiveRecord::Base
  include Royal::Points

  def self.create_table
    connection.create_table(:users) do |t|
      t.string :username
      t.timestamps
    end
  end
end
