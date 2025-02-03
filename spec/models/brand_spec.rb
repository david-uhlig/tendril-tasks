require 'rails_helper'

RSpec.describe Brand, type: :model do
  let(:logo) { File.open(Rails.root.join('spec', 'assets', 'images', 'for-tests.jpg')) }
  let(:brand) { Brand.new }
  let!(:setting) { create(:setting) }

  describe '#updated_at' do
    it 'returns the maximum updated_at from settings' do
      expect(brand.updated_at).to eq(Setting.maximum(:updated_at))
    end
  end

  describe '#logo' do
    context 'when brand logo is set' do
      it 'returns the brand logo' do
        Setting.brand_logo = logo
        expect(brand.logo).to eq(Setting.brand_logo)
      end
    end

    context 'when brand logo is not set' do
      it 'returns nil' do
        expect(brand.logo).to be_nil
      end
    end
  end

  describe '#name' do
    context 'when brand name is set' do
      it 'returns the brand name' do
        Setting.brand_name = 'Custom Brand'
        expect(brand.name).to eq('Custom Brand')
      end
    end

    context 'when brand name is not set' do
      it 'returns nil' do
        expect(brand.name).to be_nil
      end
    end
  end

  describe '#display_name?' do
    context "when display brand name is not set" do
      it 'returns true' do
        expect(brand.display_name?).to be true
      end
    end

    context "when display brand name is set to false" do
      it 'returns false' do
        Setting.display_brand_name = false
        expect(brand.display_name?).to be false
      end
    end

    context "when display brand name is set to true" do
      it 'returns true' do
        Setting.display_brand_name = true
        expect(brand.display_name?).to be true
      end
    end
  end
end
