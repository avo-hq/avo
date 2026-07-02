# frozen_string_literal: true

require "rails_helper"

# Integration-style spec for spec/dummy/db/seeds.rb.
#
# Runs the seeder against the test DB and asserts post-conditions. Wrapped in
# a transactional fixture (default), so records are rolled back afterwards.
# Tagged :slow so CI can skip it by default; run on demand with
#   bundle exec rspec spec/dummy/db/seeds_spec.rb --tag slow
RSpec.describe "spec/dummy/db/seeds.rb", :slow do
  let(:seed_path) { Rails.root.join("db", "seeds.rb") }

  it "exists" do
    expect(File.exist?(seed_path)).to be(true)
  end

  context "when loaded against a clean schema" do
    before(:all) do
      load Rails.root.join("db", "seeds.rb")
    end

    it "creates the admin login user" do
      admin = User.find_by(email: "hi@avohq.io")
      expect(admin).not_to be_nil
      expect(admin.roles["admin"]).to be(true)
    end

    it "creates the expected dataset shape (within tolerance)" do
      expect(User.count).to be_between(50, 60)
      # 25 explicit posts, plus ~25% of 32 reviews create a post as reviewable.
      expect(Post.count).to be_between(25, 45)
      expect(Project.count).to eq(30)
      expect(Course.count).to eq(150)
      expect(Course::Link.count).to eq(450)
      expect(Galaxy::Planet.count).to eq(8)
      expect(Galaxy::Planet::Satellite.count).to eq(20)
      expect(City.count).to eq(27)
      expect(Product.count).to eq(4)
    end

    it "attaches an image to every product" do
      expect(Product.all).to all(satisfy { |p| p.image.attached? })
    end

    it "attaches local cover images to the explicitly-created posts (no picsum HTTP)" do
      posts_with_covers = Post.all.select { |p| p.cover.attached? }
      expect(posts_with_covers.size).to be >= 25

      filenames = posts_with_covers.map { |p| p.cover.attachment.blob.filename.to_s }
      expect(filenames).to all(satisfy { |fn| LOCAL_COVERS.include?(fn) })
    end

    it "does not reference picsum.photos in the seeder source (except the Playground field)" do
      source = File.read(Rails.root.join("db", "seeds.rb"))
      # The Playground record's `external_image_url` legitimately stores a picsum
      # URL string -- nothing fetches it. Anything else would mean an HTTP fetch
      # snuck back in.
      picsum_lines = source.lines.grep(/picsum\.photos/)
      expect(picsum_lines.size).to be <= 1
    end

    it "creates a Playground record" do
      expect(Playground.count).to eq(1)
    end
  end
end
