module SvgDrawer
  class Path < Base
    # Required since there is no known way to calculate them
    requires :width
    requires :height

    # Retranslate ensures the parent element can correctly draw borders
    defaults scale: [1, 1],
             rotate: 0,
             overflow: true,      # false not supported
             retranslate: false   # true not supported

    def initialize(path_components, defaults = {})
      super(defaults)
      @components = path_components
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

    def _render(parent)
      # No idea how to find boundary coordinates
      raise NotImplementedError if param(:retranslate)

      Utils::RasemWrapper.group(parent, class: 'path') do |path_group|
        @components.each { |path| path_group.path(d: path) }
      end.scale(*param(:scale))
    end
  end
end
