module SvgDrawer
  class Cell < Base
    def width
      return @width if @width
      ensure_complete!
      @width = [param(:width, 0), @content.width].max
    end

    def height
      return @height if @height
      ensure_complete!
      @height = [param(:height, 0), @content.height].max
    end

    def incomplete
      @content.nil? ? self : @content.incomplete
    end

    def content(element = nil)
      return @content unless element
      raise TypeError, 'Argument must to respond to #draw' unless element.respond_to?(:draw)
      element.update_params!(inherited: child_params)
      @content = element
    end

    def text_box(text, params = {})
      @content = TextBox.new(text, params.merge(inherited: child_params))
    end

    def path(path_components, params = {})
      @content = Path.new(path_components, params.merge(inherited: child_params))
    end

    def polyline(points, params = {})
      @content = Polyline.new(points, params.merge(inherited: child_params))
    end

    def multipolyline(strokes, params = {})
      @content = Multipolyline.new(strokes, params.merge(inherited: child_params))
    end

    def line(points, params = {})
      @content = Line.new(points, params.merge(inherited: child_params))
    end

    def circle(center, radius, params = {})
      @content = Circle.new(center, radius, params.merge(inherited: child_params))
    end

    def image(href, params = {})
      @content = Image.new(href, params.merge(inherited: child_params))
    end

    #
    # See Row#draw for info on col_width and row_height
    #
    # @param  parent [Rasem::SVGTagWithParent]
    # @param  col_width [Integer]  Table-wide max colum width
    # @param  row_height [Integer]  Table-wide max row height
    # @return  [Rasem::SVGTagWithParent]
    #
    def _draw(parent)
      Utils::RasemWrapper.group(parent, class: param(:class), id: param(:id)) do |cell_group|
        draw_border(cell_group)
        @content.draw(cell_group, debug: @debug)
      end
    end
  end
end
