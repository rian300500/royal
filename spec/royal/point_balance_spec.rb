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

  it 'is readonly once created' do
    point_balance.save!
    expect(point_balance).to be_readonly
  end
end
