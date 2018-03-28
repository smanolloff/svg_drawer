module SvgDrawer
  class Image < Base
    # Required since there is no known way to calculate them
    requires :width
    requires :height

    # Retranslate ensures the parent element can correctly draw borders
    defaults scale: [1, 1],
             overflow: true,
             retranslate: false   # true not supported

    def initialize(href, params = {})
      @href = href
      super(params)
    end

    def width
      param(:width)
    end

    def height
      param(:height)
    end

    def incomplete
      false
    end

    private

    def _draw(parent)
      # No idea how to find boundary coordinates
      raise NotImplementedError if param(:retranslate)

      Utils::RasemWrapper.group(parent, class: 'image') do |image_group|
        w = param(:width) unless param(:overflow)
        h = param(:height) unless param(:overflow)

        res = image_group.image(nil, nil, w, h, @href)
        %i[x y width height].each { |k| res.attributes.delete(k) if res.attributes[k].blank? }
        res
      end.scale(*param(:scale))
    end
  end
end
