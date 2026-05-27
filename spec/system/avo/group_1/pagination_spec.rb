require "rails_helper"

RSpec.feature "Pagination", type: :system do
  describe "navigation rendering" do
    let!(:published_posts) { create_list(:post, 40, published_at: rand((DateTime.now - 3.months)..DateTime.now)) }
    let!(:unpublished_post) { create :post, name: "Unpublished post", published_at: nil }

    it "keeps wide pagination with edge pages and gaps on middle pages" do
      last_page = Post.count

      visit "/admin/resources/posts?view_type=table&per_page=1&page=14"
      wait_for_loaded

      within("nav.pagy.series-nav") do
        expect(page).to have_css("a", text: "1")
        expect(page).to have_css("a", text: "12")
        expect(page).to have_css("a", text: "13")
        expect(page).to have_css("[aria-current='page']", text: "14")
        expect(page).to have_css("a", text: "15")
        expect(page).to have_css("a", text: "16")
        expect(page).to have_css("a", text: last_page.to_s)
        expect(page).to have_css("a[role='separator']")
      end
    end
  end

  describe "info copy for single-page results" do
    it "renders '1 record' when only one record exists" do
      Post.destroy_all
      create :post

      visit "/admin/resources/posts?view_type=table"
      wait_for_loaded

      within(".pagination__info") do
        expect(page).to have_text("1 record")
        expect(page).not_to have_text("of")
        expect(page).not_to have_text("-")
      end
    end

    it "renders 'N records' when all records fit on one page" do
      Post.destroy_all
      create_list :post, 5

      visit "/admin/resources/posts?view_type=table&per_page=24"
      wait_for_loaded

      within(".pagination__info") do
        expect(page).to have_text("5 records")
        expect(page).not_to have_text("of")
        expect(page).not_to have_text("-")
      end
    end
  end
end
