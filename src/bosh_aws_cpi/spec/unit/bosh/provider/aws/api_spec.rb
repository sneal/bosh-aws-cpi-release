require "spec_helper"

module Bosh::Provider::AWS
  describe API do
    subject(:api) { API.new(config, logger, ec2, elb) }

    let(:config)  { { 'region' => 'region-name' } }
    let(:logger)  { nil }
    let(:ec2)     { instance_double(::AWS::EC2, client: Object.new) }
    let(:elb)     { instance_double(::AWS::ELB, client: Object.new) }

    describe '#initialize' do
      it 'creates and configures EC2 and ELB clients' do
        expect(::AWS::EC2).to receive(:new).with({ region: 'region-name' })
        expect(::AWS::ELB).to receive(:new).with({ region: 'region-name' })
        API.new(config, logger)
      end

      context 'when provided EC2 and ELB clients' do
        it 'does not create those' do
          expect(::AWS::EC2).to_not receive(:new)
          expect(::AWS::ELB).to_not receive(:new)
          API.new(config, logger, ec2, elb)
        end
      end
    end

    describe '#create_instance' do
      let(:instance_id)  { 'instance-abc' }
      let(:ec2_instance) { OpenStruct.new(instance_id: instance_id) }
      let(:ec2_response) { OpenStruct.new(instances_set: [ec2_instance]) }
      let(:params)       { { key: 'value' } }

      it 'creates an EC2 instance and returns the instance ID' do
        expect(ec2.client).to receive(:run_instances)
          .with(params)
          .and_return(ec2_response)

        expect(api.create_instance(params)).to eq(instance_id)
      end
    end
  end
end
