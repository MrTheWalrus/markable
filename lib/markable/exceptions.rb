module Markable
  class WrongMarkableType < Exception
    def initialize
      super 'Wrong markable type'
    end
  end

  class WrongMarkType < Exception
    def initialize
      super 'Wrong mark type'
    end
  end
end
