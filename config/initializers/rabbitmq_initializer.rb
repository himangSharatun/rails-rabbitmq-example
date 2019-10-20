class RabbitQueueService
  def self.logger
    Rails.logger.tagged('bunny') do
      @@_logger ||= Rails.logger
    end
  end

  def self.connection
    @@_connection ||= begin
      instance = Bunny.new(
        addresses: ENV['BUNNY_AMQP_ADDRESSES'].split(','),
        username:  ENV['BUNNY_AMQP_USER'],
        password:  ENV['BUNNY_AMQP_PASSWORD'],
        vhost:     ENV['BUNNY_AMQP_VHOST'],
        automatically_recover: true,
        connection_timeout: 2,
        continuation_timeout: (ENV['BUNNY_CONTINUATION_TIMEOUT'] || 10_000).to_i,
        logger: RabbitQueueService.logger
      )
      instance.start
      instance
    end
  end

  ObjectSpace.define_finalizer(RailsMessageQueue::Application, proc { puts "Closing rabbitmq connections"; RabbitQueueService.connection&.close })

  # def self.with(&block)
  #   return if self.connection.nil?
  #   counter = 0
  #   begin
  #     channel = self.connection.create_channel
  #     yield channel
  #   rescue Bunny::NetworkFailure, Bunny::TCPConnectionFailed => e
  #     Rails.logger.error(tags: [:bunny, :network, :error], message: e.message)
  #     @@_connection = nil
  #     counter += 1
  #     Rails.logger.info(tags: [:bunny, :retry], message: "Retrying to send the event: #{counter}")
  #     retry if counter <= 3
  #   rescue StandardError => e
  #     Rails.logger.error(tags: [:bunny, :error, :unknown], message: e.message)
  #   ensure
  #     channel.close if channel
  #   end
  # end
end
