require 'rails_helper'

RSpec.describe Avo::EventsController, type: :controller do
  it "finds the meta value" do
    get :index

    expect(assigns(:resource).get_field(:body).meta).to eq({foo: :bar})
  end
end
