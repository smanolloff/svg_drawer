module SvgDrawer
  class Row < Base
    requires :columns

    special :width        # row width is not the same as cell width
    special :columns      # makes no sense for a cell
    special :col_widths   # makes no sense for a cell

    def width
      ensure_complete!
      sum_width = cell_widths.reduce(&:+)
      [param(:width, 0), sum_width].max
    end

    def height
      ensure_complete!
      [param(:height, 0), cell_heights.max].max
    end

    def incomplete
      cells.size != param(:columns) ? self : find_incomplete_descendant
    end

    def cell_widths
      ensure_complete!
      cells.map(&:width)
    end

    def cell_heights
      ensure_complete!
      cells.map(&:height)
    end

    def col_widths
      Table.col_widths(param(:col_widths), param(:width), param(:columns))
    end

    def cells
      @cells ||= []
    end

    def add_cell(cell)
      raise TypeError, "Expected Cell, got: #{cell.class}" unless cell.is_a?(Cell)
      cell.update_params!(inherited: cell_params)
      cells << cell
      self
    end

    #
    # @param  params [Hash]  cell params.
    # @return  [Row]  self
    #
    def cell(params = {})
      raise 'Cannot add more cells' unless incomplete
      cell = Cell.new(params.merge(inherited: cell_params))
      yield(cell)
      cells << cell
      self
    end

    def text_cell(text, params = {})
      cell(params) { |c| c.text_box(text) }
    end

    def path_cell(path_components, params = {})
      cell(params) { |c| c.path(path_components) }
    end

    def polyline_cell(points, params = {})
      cell(params) { |c| c.polyline(points) }
    end

    def multipolyline_cell(strokes, params = {})
      cell(params) { |c| c.multipolyline(strokes) }
    end

    def line_cell(points, params = {})
      cell(params) { |c| c.line(points) }
    end

    private

    #
    # A note on cell widths:
    # Cells are rendered not with their initial widths, but with the
    # table-wide maximum width for the corresponding columns.
    # This must happen at render time, as we can't know what the max col
    # width is until we have added all rows for the entire table.
    #
    # Similarly, for the heights:
    # Cells are not rendered with their initial heigths, but with the
    # row-wide maximum height.
    # This must happen at render time, as we can't know what the max cell
    # height is until we have added all cells for this row.
    #
    # @param  parent [Rasem::SVGTagWithParent]
    # @param  col_widths [Array]  Table-wide max column widths
    # @return  [Rasem::SVGTagWithParent]
    #
    def _render(parent, max_col_widths)
      Utils::RasemWrapper.group(parent, class: param(:class), id: param(:id)) do |row_group|
        draw_border(row_group, width_override: max_col_widths.reduce(&:+))

        cells.zip(max_col_widths).reduce(0) do |x, (cell, col_width)|
          cell.render(row_group).translate(x, 0)
          x + col_width
        end
      end
    end

    def cell_params
      return child_params unless col_widths && col_widths[cells.size]
      child_params.merge(width: col_widths[cells.size])
    end

    def find_incomplete_descendant
      cells.each.with_object(nil) do |cell, _|
        res = cell.incomplete
        break res if res
      end
    end
  end
end
