module Bosh
  module Cloud::AWS
    module Models
      class Instance
        attr_reader :id

        def initialize(id)
          @id = id
        end
      end
    end
  end
end
