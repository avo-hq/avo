require "rails_helper"

# Post's resource finds rows by slug alone (`where(slug:)` for a set, `find_by_slug` for one), and the
# model's `to_param` is that slug: the shape of a friendly_id or hashid app.
RSpec.describe Avo::Resources::Base, ".find_records" do
  let!(:first) { create :post }
  let!(:second) { create :post }

  it "finds records by their param, in the order asked, with nil for an id that names none" do
    records = Avo::Resources::Post.find_records([second.to_param, "missing", first.to_param], query: Post.all)

    expect(records).to eq [second, nil, first]
  end

  it "keeps what a finder that ignores its query names inside that query" do
    allow(Avo::Resources::Post).to receive(:find_record_method).and_return(-> { Post.where(slug: id) })

    records = Avo::Resources::Post.find_records([first.to_param, second.to_param], query: Post.where.not(id: second.id))

    expect(records).to eq [first, nil]
  end
end
