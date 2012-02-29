module Refinery
  module Supplier
    class Version
      @major = 1
      @minor = 8
      @tiny  = 0

      class << self
        attr_reader :major, :minor, :tiny

        def to_s
          [@major, @minor, @tiny].compact.join('.')
        end
      end
    end
  end
end
