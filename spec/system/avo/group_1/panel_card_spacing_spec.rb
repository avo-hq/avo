require "rails_helper"

# AVO-1499: sibling cards declared in the same `panel do ... end` block render as
# adjacent `.panel__body > .card` elements. The panel body is a plain block
# container, so without a rule of its own the cards sit back to back with their
# borders touching.
RSpec.describe "panel card spacing", type: :system do
  let!(:person) { create :person }

  # `--spacing` * 4 -> 1rem. The panel's own `gap-y-4` between header, content and
  # footer uses the same step, so cards line up with the rest of the panel rhythm.
  let(:expected_gap) { 16 }

  # Declared here rather than leaning on the dummy app's Person resource: another
  # spec in this group swaps that resource's items out, so a shared definition
  # would make this spec order-dependent.
  #
  # The first panel is the reported shape (two cards, one body); the second gives
  # the lone-card case something to measure.
  before do
    Avo::Resources::Person.with_temporary_items do
      panel title: "Sibling cards" do
        card title: "First card" do
          field :name, as: :text
        end

        card title: "Second card" do
          field :type, as: :text
        end
      end

      panel title: "Lone card" do
        card title: "Only card" do
          field :name, as: :text
        end
      end
    end

    visit avo.resources_person_path(person)

    expect(page).to have_text "First card"
    expect(page).to have_text "Second card"
  end

  after { Avo::Resources::Person.restore_items_from_backup }

  # Distance between the bottom border of one card and the top border of the next.
  # Measuring the rendered boxes keeps the assertion honest about the visual
  # result rather than about the property that happens to produce it.
  def gap_between_panel_cards
    page.evaluate_script(<<~JS)
      (() => {
        const body = [...document.querySelectorAll('.panel__body')].find(
          (candidate) => candidate.querySelectorAll(':scope > .card').length > 1
        )
        if (!body) return null

        const [first, second] = body.querySelectorAll(':scope > .card')

        return second.getBoundingClientRect().top - first.getBoundingClientRect().bottom
      })()
    JS
  end

  it "separates sibling cards inside a panel body" do
    expect(gap_between_panel_cards).to be_within(1).of(expected_gap)
  end

  # The single-card case is the common one; it must not gain a stray offset from
  # the sibling rule.
  it "leaves a lone card in a panel body flush with the panel" do
    lone_card_offset = page.evaluate_script(<<~JS)
      (() => {
        const body = [...document.querySelectorAll('.panel__body')].find(
          (candidate) => candidate.querySelectorAll(':scope > .card').length === 1
        )
        if (!body) return null

        const card = body.querySelector(':scope > .card')

        return card.getBoundingClientRect().top - body.getBoundingClientRect().top
      })()
    JS

    expect(lone_card_offset).to be_within(1).of(0)
  end
end
