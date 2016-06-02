module Bosh
  module Cloud::AWS
    class API
      def initialize(config, logger, ec2 = nil, elb = nil)
        @config = config
        @logger = logger
        @ec2    =  ec2 || ::AWS::EC2.new(properties)
        @elb    =  elb || ::AWS::ELB.new(properties)
      end

      def create_instance(params)
        response = @ec2.client.run_instances(params)
        response.instances_set.first.instance_id
      end

      private

      def properties
        @properties ||= {}.tap do |h|
          h[:region] = @config['region']
        end
      end
    end
  end
end
