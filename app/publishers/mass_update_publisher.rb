class MassUpdatePublisher
  QUEUE_NAME = 'user.mass_update_using_csv'.freeze

  def initialize(mutations)
    @mutations = mutations
  end

  def publish(options = {})
    channel = RabbitQueueService.connection.create_channel
    exchange = channel.exchange(
      ENV['BUNNY_AMQP_EXCHANGE'],
      type: 'x-delayed-message',
      durable: true,
      arguments: {
        'x-delayed-type': 'direct',
      }
    )
    headers = { 'x-delay' => options[:delay_time].to_i * 1_000 } if options[:delay_time].present?
    exchange.publish(payload.to_json, routing_key: QUEUE_NAME, headers: headers)
  end

  private

  def payload
    {
      mutations: @mutations
    }
  end
end