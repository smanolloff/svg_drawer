module SvgDrawer
  class Path < Base
    # Required since there is no known way to calculate them
    requires :width
    requires :height

    # Retranslate ensures the parent element can correctly draw borders
    defaults fill: 'black',
             stroke: 'none',
             scale: [1, 1],
             overflow: true,      # false not supported
             retranslate: false   # true not supported

    def initialize(path_components, params = {})
      @components = path_components
      super(params)
    end

    # No idea how to compute dimensions for paths
    def width
      raise NotImplementedError unless param(:overflow)
      param(:width)
    end

    def height
      raise NotImplementedError unless param(:overflow)
      param(:height)
    end

    def incomplete
      false
    end

    private

    def _draw(parent)
      # No idea how to find boundary coordinates
      raise NotImplementedError if param(:retranslate)

      style = {}
      style[:fill] = param(:fill)
      style[:stroke] = param(:stroke)

      Utils::RasemWrapper.group(parent, class: 'path') do |path_group|
        @components.each { |path| path_group.path(d: path, style: style) }
      end.scale(*param(:scale))
    end
  end
end
