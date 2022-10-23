require 'rails_helper'

RSpec.describe 'raise_error_on_missing_policy', type: :feature do
  before { Avo.configuration.raise_error_on_missing_policy = true }
  after { Avo.configuration.raise_error_on_missing_policy = false }

  describe 'index?' do
    it 'fails with a missing policy' do
      expect {
        visit '/admin/resources/people'
      }.to raise_error Avo::NoPolicyError
    end

    it 'succeeds with a present policy' do
      RSpec::Expectations.configuration.on_potential_false_positives = :nothing
      expect {
        visit '/admin/resources/projects'
      }.not_to raise_error an_instance_of(Avo::NoPolicyError)
      RSpec::Expectations.configuration.on_potential_false_positives = :warn
    end
  end
end
