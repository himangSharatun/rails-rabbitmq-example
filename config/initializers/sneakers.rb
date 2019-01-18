# config/initializers/sneakers.rb
require 'sneakers'
require 'sneakers/handlers/maxretry'

module Connection
  def self.sneakers
    @_sneakers ||= begin
      Bunny.new(
        addresses: ENV['BUNNY_AMQP_ADDRESSES']&.split(','),
        username:  ENV['BUNNY_AMQP_USER'],
        password:  ENV['BUNNY_AMQP_PASSWORD'],
        vhost:     ENV['BUNNY_AMQP_VHOST'],
        automatically_recover: true,
        connection_timeout: 2,
        continuation_timeout: (ENV['BUNNY_CONTINUATION_TIMEOUT'] || 10_000).to_i,
        logger:  LogStashLogger.new(type: :stdout, formatter: :json_lines)
      )
    end
  end
end



Sneakers.configure  connection: Connection.sneakers,
                    exchange: ENV['SNEAKERS_AMQP_EXCHANGE'],            # AMQP exchange
                    exchange_options: {
                      durable: true,
                      type: 'x-delayed-message',
                      arguments: {
                        'x-delayed-type': :direct,
                      },
                    },
                    runner_config_file: nil,                             # A configuration file (see below)
                    metric: nil,                                         # A metrics provider implementation
                    daemonize:false,                                     # Send to background
                    workers: ENV['SNEAKERS_WORKER'].to_i,                # Number of per-cpu processes to run
                    log: STDOUT,                                         # Log file
                    pid_path: 'sneakers.pid',                            # Pid file
                    timeout_job_after: 5.minutes,                        # Maximal seconds to wait for job
                    prefetch: ENV['SNEAKERS_PREFETCH'].to_i,             # Grab 10 jobs together. Better speed.
                    threads: ENV['SNEAKERS_THREADS'].to_i,               # Threadpool size (good to match prefetch)
                    env: ENV['RAILS_ENV'],                               # Environment
                    durable: true,                                       # Is queue durable?
                    ack: true,                                           # Must we acknowledge?
                    heartbeat: 5,                                        # Keep a good connection with broker
                    # TODO: implement exponential back-off retry
                    handler: Sneakers::Handlers::Maxretry,
                    retry_max_times: 10,                                  # how many times to retry the failed worker process
                    retry_timeout: 3 * 60 * 1000                        # how long between each worker retry duration

Sneakers.logger = LogStashLogger.new(type: :stdout, formatter: :json_lines)
Sneakers.logger.level = Logger::INFO
