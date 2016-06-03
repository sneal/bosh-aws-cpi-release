module Bosh
  module Provider::AWS
    module Models
      class Instance
        attr_reader :id

        def initialize(id)
          @id = id
        end

        def configure_network(spec)
          @network = 'network'
        end

        def has_network?
          @network != nil
        end
      end
    end
  end
end
