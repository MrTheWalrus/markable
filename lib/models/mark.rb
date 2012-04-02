module Markable
  class Mark < ActiveRecord::Base
    belongs_to :markable, :polymorphic => true
    belongs_to :marker, :polymorphic => true
    
    attr_accessible :markable_id, :markable_type, :marker_id, :marker_type, :mark
  end
end
