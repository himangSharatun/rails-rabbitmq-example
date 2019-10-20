class MassUpdateWorker
  include Sneakers::Worker

  QUEUE_NAME = MassUpdatePublisher::QUEUE_NAME
  from_queue QUEUE_NAME, arguments: { 'x-dead-letter-exchange': "#{QUEUE_NAME}-retry" }

  def work(msg)
    data = ActiveSupport::JSON.decode(msg)
    data["mutations"].each do |mutation |
      update_balance(mutation.to_h)
    end
    ack!
  rescue StandardError => e
    create_log(false, data, { message: e.message })
  end

  private

  def update_balance(mutation)
    user = User.find_by(username: mutation["username"].to_s)
    user.balance += mutation["amount"].to_i
    user.save!
  rescue StandardError => e
    create_log(false, mutation, { message: e.message })
  end

  def create_log(success, payload, message = {})
    message = {
      success: success,
      payload: payload
    }.merge(message).to_json

    severity = success ? :info : :error
    Rails.logger.send(severity, message)
  end
end