module SvgDrawer
  class Line < Polyline
    defaults Polyline.default_params

    def incomplete
      @points.size != 4 && self
    end
  end
end
