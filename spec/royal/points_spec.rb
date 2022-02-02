# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Royal::Points do
  subject(:user) { User.create!(username: 'Test') }

  describe '#current_points' do
    subject(:current_points) { user.current_points }

    it 'returns the points balance' do
      Royal::PointBalance.apply_change_to_points(user, 100)
      expect(current_points).to eq(100)
    end

    it 'returns the latest balance when multiple records are present' do
      5.times do
        Royal::PointBalance.apply_change_to_points(user, 100)
      end

      expect(current_points).to eq(500)
    end

    it 'returns zero when there is no points balance' do
      expect(current_points).to be_zero
    end
  end

  describe '#add_points' do
    subject(:add_points) { user.add_points(amount, reason: reason, pointable: pointable) }

    let(:amount) { 100 }
    let(:reason) { 'Example reason' }
    let(:pointable) { nil }

    it 'adds points to the user' do
      expect { add_points }.to change { user.current_points }.by(amount)
    end

    it 'returns the new points balance' do
      expect(add_points).to eq(amount)
    end

    it 'creates a new point balance' do
      expect { add_points }.to change { user.point_balances.count }.by(1)
    end
  end

  describe '#subtract_points' do
    subject(:subtract_points) { user.subtract_points(amount, reason: reason, pointable: pointable) }

    let(:amount) { 100 }
    let(:reason) { 'Example reason' }
    let(:pointable) { nil }

    before(:each) do
      user.add_points(250)
    end

    it 'spends points from the user' do
      expect { subtract_points }.to change { user.current_points }.by(-amount)
    end

    it 'returns the new points balance' do
      expect(subtract_points).to eq(250 - amount)
    end

    it 'creates a new point balance' do
      expect { subtract_points }.to change { user.point_balances.count }.by(1)
    end

    context 'when the user has insufficient points' do
      before(:each) do
        user.subtract_points(200)
      end

      it 'raises an InsufficientPointsError' do
        expect { subtract_points }.to raise_error(Royal::InsufficientPointsError)
      end

      it "does not change the user's points balance" do
        expect { subtract_points rescue nil }.not_to change { user.current_points }
      end

      it 'does not create a new point balance' do
        expect { subtract_points rescue nil }.not_to change { user.point_balances.count }
      end
    end
  end
end
