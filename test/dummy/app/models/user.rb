class User < ActiveRecord::Base
  acts_as_marker
  markable_as :friendly, :by => :user
end
