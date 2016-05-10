require 'rails_helper'

RSpec.describe User, type: :model do
  let (:attributes) do
    {
      email: 'john@doe.com',
      password: 'please01',
      password_confirmation: 'please01'
    }
  end

  it 'can be created from valid attributes' do
    user = User.new attributes
    expect(user).to be_valid
  end

  describe '#email' do
    it 'is required' do
      user = User.new attributes.except(:email)
      expect(user).to have_at_least(1).error_on :email
    end
  end

  describe '#password' do
    it 'is required' do
      user = User.new attributes.except(:password)
      expect(user).to have_at_least(1).error_on :password
    end
  end

  describe '#password_confirmation' do
    it 'must match #password' do
      user = User.new attributes.merge(password_confirmation: 'somethingelse')
      expect(user).to have_at_least(1).error_on :password_confirmation
    end
  end
end
