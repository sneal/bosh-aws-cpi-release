module Bosh
  module Provider::AWS
    class CPI
      def initialize(config, api)
        @config = config
        @api    = api
        @security_group_mapper = AwsCloud::SecurityGroupMapper.new(@api.ec2)
        @instance_param_mapper = AwsCloud::InstanceParamMapper.new(@security_group_mapper)
      end

      def create_vm(agent_id, stemcell_id, resource_pool, network_spec, disk_locality = nil, environment = nil)
        # find a stemcell
        # - StemcellFinder
        # create an AWS instance
        # - as "instance"
        # configure the network for that instance
        # - result = @api.configure_network(instance)
        # update the Registry with instance & agent details
        # - registry.update(instance.id, settings)



        validate!(agent_id, stemcell_id, resource_pool, network_spec)

        instance_id = @api.create_instance(instance_parameters(stemcell_id, resource_pool, network_spec))
        instance = Models::Instance.new(instance_id)
        # instance.configure_networks(network_spec)

        # instance.network
        # instance.vip_network
        # @api.configure_network(instance)
      end

      private

      def validate!(agent_id, stemcell_id, resource_pool, network_spec)
        if !agent_id.is_a?(String)
          raise "Agent ID must be a String"
        end

        if !stemcell_id.is_a?(String)
          raise "Stemcell ID must be a String"
        end

        if !resource_pool.is_a?(Hash)
          raise "Resource Pool must be a Hash"
        end

        if !network_spec.is_a?(Hash)
          raise "Network Spec must be a Hash"
        end
      end

      def instance_parameters(stemcell_id, resource_pool, network_spec)
        {
          image_id: stemcell_id,
          instance_type: resource_pool['instance_type'],
          key_name: resource_pool['key_name'],
          iam_instance_profile: resource_pool['iam_instance_profile'],
          user_data: {}
        }
      end
    end
  end
end
