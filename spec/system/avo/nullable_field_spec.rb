require 'rails_helper'

RSpec.describe 'NullableField', type: :system do
  describe 'without input (specifying null_values: ["", "0", "null", "nil"])' do
    let!(:post) { create :post, body: nil }

    context 'show' do
      it 'displays the posts empty body (dash)' do
        visit "/avo/resources/post/#{post.id}"

        expect(find_field_value_element('body')).to have_text empty_dash
      end
    end

    context 'edit' do
      it 'has the posts body empty' do
        visit "/avo/resources/posts/#{post.id}/edit"

        expect(find_field('body').value).to eq ''
      end
    end
  end

  describe 'with regular input (specifying null_values: ["", "0", "null", "nil"])' do
    let!(:post) { create :post, body: 'descr' }

    context 'edit' do
      it 'has the posts body prefilled' do
        visit "/avo/resources/posts/#{post.id}/edit"

        expect(find_field('body').value).to eq 'descr'
      end
      it 'changes the posts body to null ("" - empty string)' do
        visit "/avo/resources/posts/#{post.id}/edit"

        fill_in 'body', with: ''
        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/posts/#{post.id}"
        expect(find_field_value_element('body')).to have_text empty_dash
      end

      it 'changes the posts body to null ("0")' do
        visit "/avo/resources/posts/#{post.id}/edit"

        fill_in 'body', with: '0'
        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/posts/#{post.id}"
        expect(find_field_value_element('body')).to have_text empty_dash
      end

      it 'changes the posts body to null ("nil")' do
        visit "/avo/resources/posts/#{post.id}/edit"

        fill_in 'body', with: 'nil'
        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/posts/#{post.id}"
        expect(find_field_value_element('body')).to have_text empty_dash
      end

      it 'changes the postss body to null ("null")' do
        visit "/avo/resources/posts/#{post.id}/edit"

        fill_in 'body', with: 'null'
        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/posts/#{post.id}"
        expect(find_field_value_element('body')).to have_text empty_dash
      end
    end
  end

  describe 'without input (without specifying null_values)' do
    let!(:project) { create :project, status: nil }

    context 'show' do
      it 'displays the projects empty status (dash)' do
        visit "/avo/resources/project/#{project.id}"

        expect(find_field_value_element('status')).to have_text empty_dash
      end
    end

    context 'edit' do
      it 'has the projects status empty' do
        visit "/avo/resources/projects/#{project.id}/edit"

        expect(find_field('status').value).to eq ''
      end
    end
  end

  describe 'with regular input (without specifying null_values)' do
    let!(:project) { create :project, status: 'rejected' }

    context 'edit' do
      it 'has the projects status prefilled' do
        visit "/avo/resources/projects/#{project.id}/edit"

        expect(find_field('status').value).to eq 'rejected'
      end
      it 'changes the projects status to null ("" - empty string)' do
        visit "/avo/resources/projects/#{project.id}/edit"

        fill_in 'status', with: ''
        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/projects/#{project.id}"
        expect(find_field_value_element('status')).to have_text empty_dash
      end
    end
  end
end
