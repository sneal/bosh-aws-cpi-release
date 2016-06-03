require "spec_helper"

module Bosh::Provider::AWS
  describe API do
    subject(:cpi) { CPI.new(config, api) }

    let(:api)     { instance_double(API) }
    let(:config)  { { } }

    before do
      allow(api).to receive(:ec2)
    end

    describe '#create_vm' do
      let(:instance_id) { 'instance-id' }
      let(:parameters) do
        {
          image_id: 'stemcell-image-id',
          instance_type: 'instance_type',
          key_name: 'key_name',
          iam_instance_profile: 'iam_instance_profile',
          user_data: {}
        }
      end
      let(:resource_pool) do
        {
          'instance_type' => 'instance_type',
          'key_name' => 'key_name',
          'iam_instance_profile' => 'iam_instance_profile'
        }
      end
      let(:network_spec) { {} }

      it 'creates an EC2 instance and returns an Instance' do
        expect(api).to receive(:create_instance)
          .with(parameters)
          .and_return(instance_id)

        instance = cpi.create_vm('agent-id', 'stemcell-id', resource_pool, network_spec)
        expect(instance.id).to eq(instance_id)
      end

      it 'configures network for the Instance' do
        expect(api).to receive(:create_instance)
          .and_return(instance_id)

        instance = cpi.create_vm('agent-id', 'stemcell-id', resource_pool, network_spec)
        expect(instance).to have_network
      end

      describe 'validations' do
        let(:arguments) { [agent_id, stemcell_id, resource_pool, network_spec] }
        let(:agent_id) { 'agent-id' }
        let(:stemcell_id) { 'stemcell-id' }
        let(:resource_pool) { { key: 'value' } }
        let(:network_spec) { { key: 'value' } }

        context 'when agent_id is not a String' do
          let(:agent_id) { nil }

          it 'raise an error' do
            expect {
              cpi.create_vm(*arguments)
            }.to raise_error("Agent ID must be a String")
          end
        end

        context 'when stemcell_id is not a String' do
          let(:stemcell_id) { nil }

          it 'raise an error' do
            expect {
              cpi.create_vm(*arguments)
            }.to raise_error("Stemcell ID must be a String")
          end
        end

        context 'when resource_pool is not a Hash' do
          let(:resource_pool) { nil }

          it 'raise an error' do
            expect {
              cpi.create_vm(*arguments)
            }.to raise_error("Resource Pool must be a Hash")
          end
        end

        context 'when network_spec is not a Hash' do
          let(:network_spec) { nil }

          it 'raise an error' do
            expect {
              cpi.create_vm(*arguments)
            }.to raise_error("Network Spec must be a Hash")
          end
        end
      end
    end
  end
end
