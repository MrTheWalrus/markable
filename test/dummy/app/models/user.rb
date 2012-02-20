class User < ActiveRecord::Base
  acts_as_marker
  markable :as => :friendly, :by => :user
end
