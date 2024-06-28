require 'rails_helper'

RSpec.describe Avo::EventsController, type: :controller do
  it "finds the meta value as a hash" do
    get :index

    expect(assigns(:resource).get_field(:body).meta).to eq({foo: :bar})
  end

  it "finds the meta value as a block" do
    get :index

    expect(assigns(:resource).get_field(:first_user).meta).to eq(:foo)
  end
end
