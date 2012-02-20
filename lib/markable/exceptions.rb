module Markable
  class WrongMarkableType < Exception
    def initialize()
      super 'Wrong markable type'
    end
  end
end
