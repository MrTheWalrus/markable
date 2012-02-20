class Admin < ActiveRecord::Base
  acts_as_marker
  #markable :as => :following, :by => :admin
end
