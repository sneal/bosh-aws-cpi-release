require "spec_helper"

module Bosh::Cloud::AWS
  describe API do
    subject(:cpi) { CPI.new(config, api) }

    let(:api)     { instance_double(API) }
    let(:config)  { { } }

    describe '#create_vm' do
      it 'creates an EC2 instance and returns an Instance' do
        instance_id = 'instance-id'

        expect(api).to receive(:create_instance)
          .with({ image_id: 'stemcell-id' })
          .and_return(instance_id)

        instance = cpi.create_vm('stemcell-id')
        expect(instance.id).to eq(instance_id)
      end
    end
  end
end
