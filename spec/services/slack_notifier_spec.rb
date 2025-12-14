require 'rails_helper'

RSpec.describe SlackNotifier do
  describe '.notify_error' do
    let(:webhook_url) { 'https://hooks.slack.com/services/TEST/WEBHOOK/URL' }
    let(:error_message) { 'Test error message' }
    let(:context) { { user_id: 123, action: 'test_action' } }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('SLACK_WEBHOOK_URL').and_return(webhook_url)
    end

    context 'with valid webhook URL' do
      before do
        stub_request(:post, webhook_url)
          .with(
            body: hash_including(
              text: /Error occurred/
            ),
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 200, body: 'ok')
      end

      it 'sends error notification to Slack' do
        result = described_class.notify_error(error_message, context)
        expect(result).to be true
      end

      it 'includes error message in notification' do
        described_class.notify_error(error_message, context)

        expect(WebMock).to have_requested(:post, webhook_url)
          .with(body: hash_including(text: /Test error message/))
      end

      it 'includes context information in notification' do
        described_class.notify_error(error_message, context)

        expect(WebMock).to have_requested(:post, webhook_url)
          .with(body: hash_including(text: /user_id: 123/))
      end
    end

    context 'when webhook URL is not configured' do
      before do
        allow(ENV).to receive(:[]).with('SLACK_WEBHOOK_URL').and_return(nil)
      end

      it 'logs warning and returns false' do
        expect(Rails.logger).to receive(:warn).with(/SLACK_WEBHOOK_URL is not configured/)

        result = described_class.notify_error(error_message, context)
        expect(result).to be false
      end
    end

    context 'when Slack API returns error' do
      before do
        stub_request(:post, webhook_url)
          .to_return(status: 500, body: 'Internal Server Error')
      end

      it 'logs error and returns false' do
        expect(Rails.logger).to receive(:error).with(/Failed to send Slack notification/)

        result = described_class.notify_error(error_message, context)
        expect(result).to be false
      end
    end

    context 'when network error occurs' do
      before do
        stub_request(:post, webhook_url)
          .to_raise(StandardError.new('Network error'))
      end

      it 'logs error and returns false' do
        expect(Rails.logger).to receive(:error).with(/Failed to send Slack notification: Network error/)

        result = described_class.notify_error(error_message, context)
        expect(result).to be false
      end
    end
  end
end
