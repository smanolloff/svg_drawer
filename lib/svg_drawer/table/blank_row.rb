module SvgDrawer
  class BlankRow < Base
    requires :columns
    requires :width
    requires :height

    def incomplete
      false
    end

    def width
      @width ||= param(:width)
    end

    def height
      @height ||= param(:height)
    end

    def cell_widths
      Array.new(param(:columns), 0)
    end

    private

    def _render(parent, _col_widths)
      Utils::RasemWrapper.group(parent, class: param(:class), id: param(:id)) do |row_group|
        draw_border(row_group)
        row_group.rectangle(0, 0, width, height, fill: 'none', stroke: 'none')
      end
    end
  end
end
