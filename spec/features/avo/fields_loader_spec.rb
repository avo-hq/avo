require "rails_helper"

# class DummyUser < Resource
#   def configure
#     @title = :name
#     @translation_key = 'avo.resource_translations.user'
#     @search = [:id, :first_name, :last_name]
#     @includes = :posts
#     @devise_password_optional = true
#   end

#   def fields(request)
#     f.id :iddd, link_to_record: true do |model, resource, view, field|
#       # abort ['qwe'].inspect
#       '123'
#     end
#   end
# end

# class DummyUser < Resource
#   def configure
#     @title = :name
#     @translation_key = 'avo.resource_translations.user'
#     @search = [:id, :first_name, :last_name]
#     @includes = :posts
#     @devise_password_optional = true
#   end

#   def fields(request)
#     f.id :iddd, link_to_record: true do |model, resource, view, field|
#       # abort ['qwe'].inspect
#       123
#     end
#   end
# end

# module Avo
#   module Actions
#     class MarkInactive < Action
#       def name
#         'Mark inactive'
#       end

#       def handle(request, models, fields)
#         models.each do |model|
#           model.update active: false

#           model.notify fields['message'] if fields['notify_user']
#         end

#         succeed 'Perfect!'
#         reload_resources
#       end

#       def fields(request)
#         f.boolean :notify_user
#         f.text :message, default: 'Your account has been marked as inactive.'
#       end
#     end
#   end
# end

# RSpec.feature 'FieldsLoader', type: :feature do
#   describe 'Resource' do
#     context 'initialized once' do
#       let(:resource) { Avo::Resources::DummyUser.new }

#       subject { resource.get_field_definitions }

#       it { is_expected.to be_a Array }
#       specify { expect(subject.first.class).to be Avo::Fields::IdField }
#       specify { expect(subject.first.id).to be :iddd }
#       specify { expect(subject.count).to be 1 }
#     end

#     context 'initialized twice' do
#       let(:resource) { Avo::Resources::DummyUser.new; Avo::Resources::DummyUser.new }

#       subject { resource.get_field_definitions }

#       it { is_expected.to be_a Array }
#       specify { expect(subject.first.class).to be Avo::Fields::IdField }
#       specify { expect(subject.first.id).to be :iddd }
#       specify { expect(subject.count).to be 1 }
#     end
#   end
# end
