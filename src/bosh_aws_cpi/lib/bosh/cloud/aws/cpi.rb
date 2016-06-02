module Bosh
  module Cloud::AWS
    class CPI
      def initialize(config, api)
        @config = config
        @api    = api
      end

      def create_vm(stemcell_id)
        instance_id = @api.create_instance({ image_id: stemcell_id })
        Models::Instance.new(instance_id)
      end
    end
  end
end
