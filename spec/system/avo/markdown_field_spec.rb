require 'rails_helper'
WebMock.disable_net_connect!(allow_localhost: true, allow: 'chromedriver.storage.googleapis.com')

RSpec.describe 'MarkdownField', type: :system do
  describe 'without value' do
    let!(:project) { create :project, name: 'Test', users_required: 20 }

    context 'show' do
      it 'displays the projects empty description (dash)' do
        visit "/avo/resources/projects/#{project.id}"

        expect(find_field_element('description')).to have_text empty_dash
      end
    end

    context 'edit' do
      it 'has the projects description label and empty markdown editor and placeholder' do
        visit "/avo/resources/projects/#{project.id}/edit"

        description_element = find_field_element('description')
        expect(description_element).to have_text 'Description'

        within(description_element) {
          expect(find(:xpath, "//textarea[@class='auto-textarea-input no-border no-resize']")[:placeholder]).to have_text('Description')
          expect(find(:xpath, "//textarea[@class='auto-textarea-input no-border no-resize']")[:value]).to have_text('')
        }
      end

      it 'change the projects description' do
        visit "/avo/resources/projects/#{project.id}/edit"

        textarea_markdown = find(:xpath, "//textarea[@class='auto-textarea-input no-border no-resize']")
        textarea_markdown.fill_in with: 'Works for us!!! \n Hello'

        click_on 'Save'
        wait_for_loaded

        click_on 'Show Content'

        description_element = find_field_element('description')
        within(description_element) {
          expect(find(:xpath, "//div[@class='v-show-content scroll-style scroll-style-border-radius']")).to have_text('Works for us!!!')
          expect(find(:xpath, "//div[@class='v-note-show single-show']").native.attribute('outerHTML')).to have_text('<p>Works for us!!! \n Hello</p>')
        }
      end
    end
  end

  describe 'with regular value' do
    let!(:markup_description) { '### Header 3' }

    let!(:project) { create :project, name: 'TestRegular', users_required: 20, description: markup_description }

    context 'show' do
      it 'displays the projects description' do
        visit "/avo/resources/projects/#{project.id}"

        click_on 'Show Content'

        expect(find_field_element('description')).to have_text 'Header 3'
        expect(find(:xpath, "//div[@class='v-note-show single-show']").native.attribute('outerHTML')).to have_content '<h3><a id="Header_3_0"></a>Header 3</h3>'
      end
    end

    context 'edit' do
      it 'has the projects description label' do
        visit "/avo/resources/projects/#{project.id}/edit"

        description_element = find_field_element('description')

        expect(description_element).to have_text 'Description'
      end

      it 'has filled simple header in markdown editor' do
        visit "/avo/resources/projects/#{project.id}/edit"

        description_element = find_field_element('description')

        within(description_element) {
          expect(find(:xpath, "//textarea[@class='auto-textarea-input no-border no-resize']")[:value]).to have_text('### Header 3')
        }
      end

      it 'change the projects description markdown to more complicated markdown language' do
        visit "/avo/resources/projects/#{project.id}/edit"

        find("button[class='op-icon fa fa-mavon-trash-o']").click

        textarea_markdown = find(:xpath, "//textarea[@class='auto-textarea-input no-border no-resize']")
        textarea_markdown.fill_in with: "## Code \nInline `code` \n```js \nSample text here... \n``` \n--- Ordered \n1. Lorem ipsum dolor sit amet \n2. Consectetur adipiscing elit".html_safe

        click_on 'Save'
        wait_for_loaded

        click_on 'Show Content'

        description_element = find_field_element('description')
        within(description_element) {
          expect(find(:xpath, "//div[@class='v-show-content scroll-style scroll-style-border-radius']")).to have_text('Code')
          expect(find(:xpath, "//div[@class='v-show-content scroll-style scroll-style-border-radius']")).to have_text('Sample text here...')
          expect(find(:xpath, "//div[@class='v-show-content scroll-style scroll-style-border-radius']")).to have_text('Lorem ipsum dolor sit amet')
          expect(find(:xpath, "//div[@class='v-show-content scroll-style scroll-style-border-radius']")).to have_text('Consectetur adipiscing elit')

          expect(find(:xpath, "//div[@class='v-note-show single-show']").native.attribute('outerHTML')).to have_text('<h2><a id="Code_0"></a>Code</h2>')
          expect(find(:xpath, "//div[@class='v-note-show single-show']").native.attribute('outerHTML')).to have_text('Inline <code>code</code>')
          expect(find(:xpath, "//div[@class='v-note-show single-show']").native.attribute('outerHTML')).to have_text('<li>Lorem ipsum dolor sit amet</li>')
        }
      end
    end
  end
end
