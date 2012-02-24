class Food < ActiveRecord::Base
  markable_as :favorite
  markable_as :hated, :by => :user
end
