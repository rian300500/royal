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
      expect(add_points).to eq(100)
    end

    it 'creates a new point balance' do
      expect { add_points }.to change { user.point_balances.count }.by(1)
    end

    context 'when supplied with a negative amount' do
      let(:amount) { -100 }

      before(:each) do
        user.add_points(100)
      end

      it 'subtracts points from the user' do
        expect { add_points }.to change { user.current_points }.by(amount)
      end

      it 'returns the new points balance' do
        expect(add_points).to eq(0)
      end

      it 'raises an InsufficientPointsError if the resulting balance would be negative' do
        user.add_points(-50)
        expect { add_points }.to raise_error(Royal::InsufficientPointsError)
      end
    end
  end

  describe '#subtract_points' do
    subject(:subtract_points) { user.subtract_points(amount, reason: reason, pointable: pointable, allow_negative_balance: allow_negative_balance) }

    let(:amount) { 100 }
    let(:reason) { 'Example reason' }
    let(:pointable) { nil }
    let(:allow_negative_balance) { false }

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

    context 'when a negative balance is permitted' do
      let(:allow_negative_balance) { true }

      before(:each) do
        user.subtract_points(200)
      end

      it 'spends points from the user' do
        expect { subtract_points }.to change { user.current_points }.by(-amount)
      end

      it 'returns the new points balance' do
        expect(subtract_points).to eq(-50)
      end

      it 'allows points to be subsequently added' do
        subtract_points
        expect(user.add_points(100)).to eq(50)
      end

      it 'does not allow points to be subsequently subtracted without a flag' do
        subtract_points
        expect { user.subtract_points(100) }.to raise_error(Royal::InsufficientPointsError)
      end
    end
  end
end
