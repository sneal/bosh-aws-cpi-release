require "spec_helper"

module Bosh::Provider::AWS::Models
  describe Instance do
    describe '#initialize' do

    end

    describe '#has_network?' do
      context 'when network is configured' do
        it 'returns true' do
          network_spec = {
            'network-name' => {
              'type' => 'dynamic'
            }
          }
          instance = Instance.new('instance-id')

          instance.configure_network(network_spec)
          expect(instance).to have_network
        end
      end

      context 'when network is not configured' do
        it 'returns false' do
          instance = Instance.new('instance-id')
          expect(instance).to_not have_network
        end
      end
    end
  end
end
