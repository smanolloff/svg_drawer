module SvgDrawer
  class Image < Base
    # Required since there is no known way to calculate them
    requires :img_width   # raw image
    requires :img_height  # raw image

    # x_reposition and y_reposition take effect only if viewport bounds are
    # also given
    defaults scale: 1,
             x_reposition: false,     # x
             y_reposition: false      # y

    def initialize(href, params = {})
      @href = href
      super(params)
    end

    def width
      @width ||= width_unscaled * param(:scale).to_d
    end

    def height
      @height ||= height_unscaled * param(:scale).to_d
    end

    def width_unscaled
      @width_unscaled ||= param(:img_width).to_d
    end

    def height_unscaled
      @height_unscaled ||= param(:img_height).to_d
    end

    def incomplete
      false
    end

    private

    def viewport_width
      param(:width) || width
    end

    def viewport_height
      param(:height) || height
    end

    # This scale comes from preserveAspectRatio which can't be disabled
    # (librsvg crashes with OOM when preserveAspectRatio="none")
    def autoscale
      [width / param(:img_width), height / param(:img_height)].min
    end

    def _draw(parent)
      Utils::RasemWrapper.group(parent, class: 'image') do |image_group|
        x = param(:x_reposition) ? (viewport_width / 2 - width_unscaled * autoscale / 2) / param(:scale) : 0
        y = param(:y_reposition) ? (viewport_height / 2 - height_unscaled * autoscale / 2) / param(:scale) : 0
        image_group.image(x, y, width_unscaled, height_unscaled, @href, preserveAspectRatio: 'xMinYMin meet')
      end.scale(param(:scale), param(:scale))
    end
  end
end
