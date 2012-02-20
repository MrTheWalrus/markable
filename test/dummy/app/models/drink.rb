class Drink < ActiveRecord::Base
  markable :as => :favorite, :by => :admin
end
