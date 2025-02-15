require 'rails_helper'

RSpec.describe ToastNotificationsHelper, type: :helper do
  let(:resource) { double('Resource', class: double('Class', model_name: double('ModelName', human: 'Resource'))) }

  describe '#toast_message_for' do
    context 'when action is valid' do
      it 'returns the correct toast message for create action' do
        expect(helper.toast_message_for(resource, :create)).to eq(I18n.t('toast_notification.create.success', resource: 'Resource'))
      end

      it 'returns the correct toast message for update action' do
        expect(helper.toast_message_for(resource, :update)).to eq(I18n.t('toast_notification.update.success', resource: 'Resource'))
      end

      it 'returns the correct toast message for destroy action' do
        expect(helper.toast_message_for(resource, :destroy)).to eq(I18n.t('toast_notification.destroy.success', resource: 'Resource'))
      end
    end

    context 'when action is invalid' do
      it 'raises an Primer::FetchOrFallbackHelper::InvalidValueError' do
        expect {
          helper.toast_message_for(resource, :invalid_action)
        }.to raise_error(Primer::FetchOrFallbackHelper::InvalidValueError)
      end
    end

    context 'when resource is nil' do
      let(:resource) { nil }

      context "in test and development environment" do
        it 'raises ArgumentError' do
          expect {
            helper.toast_message_for(resource, :create)
          }.to raise_error(ArgumentError)
        end
      end

      context "in production environment" do
        before do
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
        end

        it 'returns the fallback name' do
          expect(helper.toast_message_for(resource, :create)).to eq(I18n.t('toast_notification.create.success', resource: 'Eintrag'))
        end
      end
    end
  end
end
