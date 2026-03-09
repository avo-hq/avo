require "rails_helper"

RSpec.feature "Pagination", type: :system do
  describe "navigation rendering" do
    let!(:published_posts) { create_list(:post, 40, published_at: rand((DateTime.now - 3.months)..DateTime.now)) }
    let!(:unpublished_post) { create :post, name: "Unpublished post", published_at: nil }

    it "keeps wide pagination with edge pages and gaps on middle pages" do
      last_page = Post.count

      visit "/admin/resources/posts?view_type=table&per_page=1&page=14"
      wait_for_loaded

      within("nav.pagy.nav, nav.pagy.series-nav") do
        expect(page).to have_css(".current, [aria-current='page']", text: "14")
        expect(page).to have_css("a", text: "1")
        expect(page).to have_css("a", text: "13")
        expect(page).to have_css("a", text: "15")
        expect(page).to have_css("a", text: last_page.to_s)
        expect(page).to have_css("a.gap, a[role='separator']")
      end
    end
  end
end
