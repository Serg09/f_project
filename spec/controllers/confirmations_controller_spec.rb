require 'rails_helper'

RSpec.describe ConfirmationsController, type: :controller do
  let (:order) { FactoryGirl.create :submitted_order }

  describe "GET #show" do
    it "returns http success" do
      get :show, id: order.confirmation
      expect(response).to have_http_status(:success)
    end
  end

end
