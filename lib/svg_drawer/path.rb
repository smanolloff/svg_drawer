module SvgDrawer
  class Path < Base
    # Required since there is no known way to calculate them
    # requires :width
    # requires :height

    requires :img_width   # raw image
    requires :img_height  # raw image

    # Retranslate ensures the parent element can correctly draw borders
    # x_reposition and y_reposition take effect only if viewport bounds are
    # also given
    defaults fill: 'black',
             stroke: 'none',
             scale: 1,
             overflow: true,      # false not supported
             x_reposition: false, # x
             y_reposition: false  # y

    def initialize(path_components, params = {})
      @components = path_components
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
      style = {}
      style[:fill] = param(:fill)
      style[:stroke] = param(:stroke)

      x = param(:x_reposition) ? (viewport_width / 2 - width_unscaled * autoscale / 2) / param(:scale) : 0
      y = param(:y_reposition) ? (viewport_height / 2 - height_unscaled * autoscale / 2) / param(:scale) : 0

      Utils::RasemWrapper.group(parent, class: 'path') do |path_group|
        @components.each { |path| path_group.path(d: path, style: style) }
      end.scale(param(:scale), param(:scale)).translate(x, y)
    end
  end
end
