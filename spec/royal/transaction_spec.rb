# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Royal::Transaction do
  subject(:transaction) { described_class.new }

  let(:user1) { User.create!(username: 'User 1') }
  let(:user2) { User.create!(username: 'User 2') }

  before(:each) do
    user1.add_points(100)
    user2.add_points(100)

    transaction.add_points(user1, 100)
    transaction.subtract_points(user2, 100)
  end

  describe '#call' do
    subject(:call) { transaction.call }

    it 'adds the points to the first user' do
      expect { call }.to change { user1.current_points }.to(200)
    end

    it 'subtracts the points from the second user' do
      expect { call }.to change { user2.current_points }.to(0)
    end

    context 'when one of the operations fails' do
      before(:each) do
        user2.subtract_points(100)
      end

      it 'raises a Royal::InsufficientPointsError' do
        expect { call }.to raise_error(Royal::InsufficientPointsRoyal)
      end

      it 'does not change the balance of either user' do
        expect { call rescue nil }.to change { user1.current_points }.by(0)
          .and change { user2.current_points }.by(0)
      end
    end
  end
end
