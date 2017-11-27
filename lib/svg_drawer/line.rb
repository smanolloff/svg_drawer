module SvgDrawer
  class Line < Polyline
    # Retranslate ensures the parent element can correctly draw borders
    defaults Polyline.default_params

    def incomplete
      @points.size != 4 && self
    end
  end
end
