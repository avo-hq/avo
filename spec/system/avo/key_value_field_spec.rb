require 'rails_helper'

RSpec.describe 'KeyValueFields', type: :system do
  describe 'without value' do
    let!(:project) { create :project , meta: '' }

    context 'show' do
      it 'displays the projects empty meta (dash)' do
        visit "/avo/resources/projects/#{project.id}"

        expect(find_field_value_element('meta')).to have_text empty_dash
      end
    end

    context 'edit' do
      it 'has the projects meta label, table header, add button' do
        visit "/avo/resources/projects/#{project.id}/edit"
        wait_for_loaded

        meta_element = find_field_element('meta')

        expect(meta_element).to have_text 'Meta'

        expect(meta_element).to have_text 'META KEY'
        expect(meta_element).to have_text 'META VALUE'
        expect(meta_element).to have_css '.flex'
        expect(meta_element).to have_css '.w-full'
        expect(meta_element).to have_css '.bg-gray-800'
        expect(meta_element).to have_css '.shadow'
        expect(meta_element).to have_css '.overflow-hidden'
        expect(meta_element).to have_css '.rounded-lg'
        expect(meta_element).to have_selector '[data-button="add-row"]'
      end

      it 'adds a row to meta table and input one row with values' do
        visit "/avo/resources/projects/#{project.id}/edit"
        wait_for_loaded

        meta_element = find_field_element('meta')

        expect(meta_element).not_to have_selector 'input[type="text"][placeholder="Meta key"]'
        expect(meta_element).not_to have_selector 'input[type="text"][placeholder="Meta value"]'
        expect(meta_element).not_to have_css '.appearance-none'
        expect(meta_element).not_to have_css '.bg-white'
        expect(meta_element).not_to have_selector '[data-button="delete-row"]'

        find('[data-button="add-row"]').click

        expect(meta_element).to have_selector 'input[type="text"][placeholder="Meta key"]'
        expect(meta_element).to have_selector 'input[type="text"][placeholder="Meta value"]'
        expect(meta_element).to have_css '.appearance-none'
        expect(meta_element).to have_selector '[data-button="delete-row"]'

        find('input[type="text"][placeholder="Meta key"]').set('Test Key')
        find('input[type="text"][placeholder="Meta value"]').set('Test Value')

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/projects/#{project.id}"

        expect(meta_element).to have_selector 'input[type="text"][placeholder="Meta key"][disabled="disabled"]'
        expect(meta_element).to have_selector 'input[type="text"][placeholder="Meta value"][disabled="disabled"]'

        keys = page.all('input[type="text"][placeholder="Meta key"][disabled="disabled"]')
        values = page.all('input[type="text"][placeholder="Meta value"][disabled="disabled"]')

        expect(keys[0].value).to eq 'Test Key'
        expect(values[0].value).to eq 'Test Value'
      end

      it 'adds a row to meta table and no input values' do
        visit "/avo/resources/projects/#{project.id}/edit"
        wait_for_loaded

        meta_element = find_field_element('meta')

        expect(meta_element).not_to have_selector 'input[type="text"][placeholder="Meta key"]'
        expect(meta_element).not_to have_selector 'input[type="text"][placeholder="Meta value"]'
        expect(meta_element).not_to have_css '.appearance-none'
        expect(meta_element).not_to have_css '.bg-white'
        expect(meta_element).not_to have_selector '[data-button="delete-row"]'

        find("[data-button='add-row']").click

        expect(meta_element).to have_selector 'input[type="text"][placeholder="Meta key"]'
        expect(meta_element).to have_selector 'input[type="text"][placeholder="Meta value"]'
        expect(meta_element).to have_css '.appearance-none'
        expect(meta_element).to have_selector '[data-button="delete-row"]'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/projects/#{project.id}"

        expect(meta_element).not_to have_selector 'input[type="text"][placeholder="Meta key"][disabled="disabled"]'
        expect(meta_element).not_to have_selector 'input[type="text"][placeholder="Meta value"][disabled="disabled"]'
      end
    end
  end

  describe 'with value' do
    let!(:meta_data) { { 'foo': 'bar', 'hey': 'hi' } }
    let!(:project) { create :project , meta: meta_data }

    context 'show' do
      it 'displays the projects meta' do
        visit "/avo/resources/projects/#{project.id}"
        wait_for_loaded

        meta_element = find_field_element('meta')

        expect(meta_element).to have_selector 'input[type="text"][placeholder="Meta key"][disabled="disabled"]'
        expect(meta_element).to have_selector 'input[type="text"][placeholder="Meta value"][disabled="disabled"]'

        keys = page.all('input[type="text"][placeholder="Meta key"][disabled="disabled"]')
        values = page.all('input[type="text"][placeholder="Meta value"][disabled="disabled"]')

        expect(keys[0].value).to eq 'foo'
        expect(values[0].value).to eq 'bar'

        expect(keys[1].value).to eq 'hey'
        expect(values[1].value).to eq 'hi'
      end
    end

    context 'edit' do
      let!(:project) { create :project , meta: meta_data }

      it 'has the projects meta label, table header, table rows (2), buttons' do
        visit "/avo/resources/projects/#{project.id}/edit"
        wait_for_loaded

        meta_element = find_field_element('meta')

        expect(meta_element).to have_text 'Meta'

        expect(meta_element).to have_text 'META KEY'
        expect(meta_element).to have_text 'META VALUE'
        expect(meta_element).to have_css '.flex'
        expect(meta_element).to have_css '.w-full'
        expect(meta_element).to have_css '.bg-gray-800'
        expect(meta_element).to have_css '.shadow'
        expect(meta_element).to have_css '.overflow-hidden'
        expect(meta_element).to have_css '.rounded-lg'

        expect(meta_element).to have_selector '[data-button="add-row"]'
        expect(meta_element).to have_selector '[data-button="delete-row"]'

        keys = page.all('input[type="text"][placeholder="Meta key"]')
        values = page.all('input[type="text"][placeholder="Meta value"]')

        expect(keys[0].value).to eq 'foo'
        expect(values[0].value).to eq 'bar'

        expect(keys[1].value).to eq 'hey'
        expect(values[1].value).to eq 'hi'
      end

      it 'deletes first row' do
        visit "/avo/resources/projects/#{project.id}/edit"
        wait_for_loaded

        delete_buttons = page.all('[data-button="delete-row"]')
        delete_buttons[0].click

        click_on 'Save'
        sleep 0.2
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/projects/#{project.id}"

        keys = page.all('input[type="text"][placeholder="Meta key"][disabled="disabled"]')
        values = page.all('input[type="text"][placeholder="Meta value"][disabled="disabled"]')

        expect(keys[0].value).to eq 'hey'
        expect(values[0].value).to eq 'hi'

        expect(keys[1]).not_to be_present
        expect(values[1]).not_to be_present
      end

      it 'deletes second row' do
        visit "/avo/resources/projects/#{project.id}/edit"
        wait_for_loaded

        meta_element = find_field_element('meta')

        expect(meta_element).to have_selector('[data-button="delete-row"]', count: 2)

        delete_buttons = page.all('[data-button="delete-row"]')

        first('[data-button="delete-row"]').click
        expect(meta_element).to have_selector('[data-button="delete-row"]', count: 1)
        first('[data-button="delete-row"]').click
        expect(meta_element).not_to have_selector('[data-button="delete-row"]')

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/projects/#{project.id}"

        expect(find_field_value_element('meta')).to have_text empty_dash
      end

      it 'checks for plus and delete tooltips on hover' do
        visit "/avo/resources/projects/#{project.id}/edit"
        wait_for_loaded

        add_button = page.find('[data-button="add-row"]')
        expect(page).not_to have_text 'New item'
        add_button.hover
        expect(page).to have_text 'New item'

        delete_buttons = page.all('[data-button="delete-row"]')
        expect(page).not_to have_text 'Remove item'
        delete_buttons[0].hover
        expect(page).to have_text 'Remove item'
      end

      it 'adds a row to meta table with key and value' do
        visit "/avo/resources/projects/#{project.id}/edit"
        wait_for_loaded

        meta_element = find_field_element('meta')

        find("[data-button='add-row']").click

        expect(meta_element).to have_selector 'input[type="text"][placeholder="Meta key"]'
        expect(meta_element).to have_selector 'input[type="text"][placeholder="Meta value"]'

        keys = page.all('input[type="text"][placeholder="Meta key"]')
        values = page.all('input[type="text"][placeholder="Meta value"]')

        keys[2].set('Test Key')
        values[2].set('Test Value')

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/projects/#{project.id}"

        keys = page.all('input[type="text"][placeholder="Meta key"][disabled="disabled"]')
        values = page.all('input[type="text"][placeholder="Meta value"][disabled="disabled"]')

        expect(keys[2].value).to eq 'Test Key'
        expect(values[2].value).to eq 'Test Value'
      end

      it 'adds a row to meta table only with key' do
        visit "/avo/resources/projects/#{project.id}/edit"
        wait_for_loaded

        meta_element = find_field_element('meta')

        find("[data-button='add-row']").click

        expect(meta_element).to have_selector 'input[type="text"][placeholder="Meta key"]'
        expect(meta_element).to have_selector 'input[type="text"][placeholder="Meta value"]'

        keys = page.all('input[type="text"][placeholder="Meta key"]')
        values = page.all('input[type="text"][placeholder="Meta value"]')

        keys[2].set('Test Key')

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/projects/#{project.id}"

        keys = page.all('input[type="text"][placeholder="Meta key"][disabled="disabled"]')
        values = page.all('input[type="text"][placeholder="Meta value"][disabled="disabled"]')

        expect(keys[2].value).to eq 'Test Key'
        expect(values[2].value).to eq ''
      end
    end
  end
end
