class SlackNotifier
  include HTTParty

  def self.notify_error(error_message, context = {})
    webhook_url = ENV["SLACK_WEBHOOK_URL"]

    unless webhook_url
      Rails.logger.warn "SLACK_WEBHOOK_URL is not configured. Skipping Slack notification."
      return false
    end

    payload = build_payload(error_message, context)

    response = post(
      webhook_url,
      body: payload.to_json,
      headers: { "Content-Type" => "application/json" }
    )

    if response.success?
      true
    else
      Rails.logger.error "Failed to send Slack notification: HTTP #{response.code}"
      false
    end
  rescue => e
    Rails.logger.error "Failed to send Slack notification: #{e.message}"
    false
  end

  private

  def self.build_payload(error_message, context)
    context_text = context.empty? ? "" : "\n*Context:*\n```#{context.inspect}```"

    {
      text: ":rotating_light: *Error occurred*\n\n*Message:* #{error_message}#{context_text}",
      username: "Error Notifier",
      icon_emoji: ":rotating_light:"
    }
  end
end
