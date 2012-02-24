class Drink < ActiveRecord::Base
  markable_as :favorite, :by => :admin
end
