# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Royal::PointBalance do
  subject(:point_balance) { described_class.new(amount: 100, owner: user, reason: reason) }

  let(:user) { User.create!(username: 'Test') }
  let(:reason) { 'Example reason' }

  it 'is valid with valid attributes' do
    expect(point_balance).to be_valid
  end

  it 'is invalid without an amount' do
    point_balance.amount = nil
    expect(point_balance).to be_invalid
  end

  it 'is invalid when the amount is zero' do
    point_balance.amount = 0
    expect(point_balance).to be_invalid
  end

  it 'is valid when the amount is negative' do
    point_balance.amount = -100
    expect(point_balance).to be_valid
  end

  it 'is invalid without an owner' do
    point_balance.owner = nil
    expect(point_balance).to be_invalid
  end

  it 'is valid without a reason' do
    point_balance.reason = nil
    expect(point_balance).to be_valid
  end

  it 'is invalid when the reason is too long' do
    point_balance.reason = 'a' * 1001
    expect(point_balance).to be_invalid
  end

  it 'sets a sequence when created' do
    point_balance.save!
    expect(point_balance.sequence).to eq(1)
  end

  it 'calculates a balance when created' do
    point_balance.save!
    expect(point_balance.balance).to eq(100)
  end

  describe '.apply_change_to_points' do
    subject(:apply_change_to_points) { described_class.apply_change_to_points(user, amount) }

    let(:user) { User.create!(username: 'Test') }
    let(:amount) { 100 }

    it 'creates a new point balance record' do
      expect { apply_change_to_points }.to change { user.point_balances.count }.by(1)
    end

    it 'returns the correct resulting balance' do
      previous_record = described_class.create!(owner: user, amount: 150)
      expect(apply_change_to_points).to eq(previous_record.balance + amount)
    end

    if Royal.config.locking.is_a?(Royal::Locking::Optimistic)
      context 'when it fails to acquire a lock fewer than the maximum number of retries' do
        before(:each) do
          latest_record  = described_class.create!(owner: user, amount: 100)
          ordered_values = Array.new(Royal.config.max_retries - 1) { nil }

          # Simulate conflicting writes N - 1 times before finally successfully getting the latest record.
          allow(described_class).to receive(:latest_for_owner).and_return(*ordered_values, latest_record)
        end

        it 'creates a new point balance record' do
          expect { apply_change_to_points }.to change { user.point_balances.count }.by(1)
        end
      end

      context 'when it fails to acquire a lock after the maximum number of retries' do
        before(:each) do
          described_class.create!(owner: user, amount: 100)
          allow(described_class).to receive(:latest_for_owner).and_return(nil)
        end

        it 'raises a Royal::SequenceError' do
          expect { apply_change_to_points }.to raise_error(Royal::SequenceError)
        end

        it 'does not write any point balance records' do
          expect { apply_change_to_points rescue nil }.not_to change { user.point_balances.count }
        end
      end
    end
  end
end
