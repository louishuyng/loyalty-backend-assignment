require "gruf"

Gruf.configure do |c|
  c.server_binding_url = '0.0.0.0:9080'
  c.grpc_logger = Logger.new(STDOUT)
  c.logger = Logger.new(STDOUT)

  Dir.glob(Rails.root.join("app/proto/*_pb.rb")).each do |file|
    require file
  end
end
