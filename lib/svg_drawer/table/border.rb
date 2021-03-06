module SvgDrawer
  module Border
    module_function

    DEFAULT_STYLE = { stroke: 'black', size: 1 }.freeze

    #
    # Draw a rectangle with the given width and height
    # The rectangle is actually 4 lines, with opacity of 1 or 0,
    # depending on the values in the `borders` array.
    # (e.g. [:left, :top])
    #
    # All lines share the same style, given by the border_style hash
    # (see DEFAULT_STYLE for possible keys and their default values)
    #
    # For debugging purposes, lines can always be drawn even when there
    # are no borders specified -- they are drawn transparent in this case.
    # Drawing opacity=0 lines helps debugging in web inspector, but has
    # some performance impact.
    #
    # @param  parent [Rasem::SVGTagWithParent]
    # @param  width [Integer]
    # @param  height [Integer]
    # @param  borders [Array] (optional)
    # @param  border_style [Hash] (optional)
    # @param  svg_class [String] (optional)
    # @param  debug [Boolean] (optional) draw invisible borders
    # @return  [Rasem::SVGTagWithParent]
    #
    def draw(parent, width, height, borders, border_style, svg_class, debug)
      return if !debug && (borders.nil? || borders.empty?)

      style = DEFAULT_STYLE.merge(border_style || {})
      style['stroke-width'] = style.delete(:size)
      borders ||= []

      line_points = {
        top: [0, 0, width, 0],
        right: [width,  0, width, height],
        bottom: [width, height, 0, height],
        left: [0, height, 0, 0]
      }

      klass = 'border'
      klass.prepend("#{svg_class} ") if svg_class

      Utils::RasemWrapper.group(parent, class: klass) do |group|
        line_points.each do |border, points|
          line_style = style.dup

          # It is useful to draw an invisible border as this
          # significantly helps debugging
          unless borders.include?(border)
            debug ? line_style[:opacity] = 0 : next
          end

          group.line(*points, line_style)
        end
      end
    end
  end
end
