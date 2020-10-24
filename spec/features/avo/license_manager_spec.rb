require 'rails_helper'

RSpec.feature 'Avo::LicenseManager', type: :feature do
  describe '.license' do
    subject(:license) { Avo::LicenseManager.new(hq_response).license }

    describe 'when should return null license' do
      let(:hq_response) { { id: 'community', valid: true }.stringify_keys }

      around :each do |example|
        ENV['RUN_WITH_NULL_LICENSE'] = '1'
        example.run
        ENV['RUN_WITH_NULL_LICENSE'] = '0'
      end

      it { is_expected.to be_a Avo::NullLicense }
    end

    context 'with community license' do
      let(:hq_response) { { id: 'community', valid: true }.stringify_keys }

      it 'returns valid license' do
        expect(license).to be_a Avo::CommunityLicense
        expect(license.id).to eql 'community'
        expect(license.valid?).to be true
        expect(license.invalid?).to be false
        expect(license.pro?).to be false
        expect(license.error).to be nil
      end
    end

    context 'with pro license' do
      context 'when valid' do
        let(:hq_response) { { id: 'pro', valid: true }.stringify_keys }

        it 'returns valid license' do
          expect(license).to be_a Avo::ProLicense
          expect(license.id).to eql 'pro'
          expect(license.valid?).to be true
          expect(license.invalid?).to be false
          expect(license.pro?).to be true
          expect(license.error).to be nil
        end
      end

      context 'when invalid' do
        let(:hq_response) { { id: 'pro', valid: false }.stringify_keys }

        it 'returns invalid license' do
          expect(license).to be_a Avo::ProLicense
          expect(license.id).to eql 'pro'
          expect(license.valid?).to be false
          expect(license.invalid?).to be true
          expect(license.pro?).to be true
          expect(license.error).to be nil
        end
      end
    end
  end
end
