class Markable::Mark < ActiveRecord::Base
  belongs_to :markable, :polymorphic => true
  belongs_to :marker, :polymorphic => true
end
