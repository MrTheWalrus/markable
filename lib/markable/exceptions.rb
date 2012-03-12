module Markable
  class WrongMarkableType < Exception
    def initialize(markable_name)
      super "Wrong markable type: ['#{Markable.markables.join("', '")}'] expected, '#{markable_name}' provided."
    end
  end

  class NotAllowedMarker < Exception
    def initialize(marker, markable, mark)
      super "Marker '#{marker.class.name}' is not allowed to mark '#{markable.class.name}' with mark '#{mark}'. Allowed markers: '#{markable.markable_marks[mark][:allowed_markers].join("', '")}'"
    end
  end
  class WrongMarkerType < Exception
    def initialize(marker_name)
      super "Wrong marker type: ['#{Markable.markers.join("', '")}'] expected, '#{marker_name}' provided."
    end
  end

  class WrongMark < Exception
    def initialize(marker, markable, mark)
      super "Wrong mark '#{mark}' for '#{markable.class.name}'. Available marks: '#{markable.markable_marks.keys.join("', '")}'"
    end
  end
end
