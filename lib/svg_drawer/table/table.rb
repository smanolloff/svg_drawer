module SvgDrawer
  class Table < Base
    requires :columns

    special :height       # table height is not the same as row height
    special :row_height   # makes no sense for a row

    defaults col_widths: nil

    #
    # Infer col_widths from width (if needed)
    #
    def self.col_widths(col_widths, width, columns)
      return if col_widths.nil? && width.nil?
      sum_width = col_widths.reduce(&:+)

      if col_widths && width && sum_width != width
        raise ArgumentError, "Sum of given col widths (#{col_widths}) doesn't match total element width (#{width})"
      end

      col_widths || Array.new(columns, width.to_d / columns)
    end

    def width
      ensure_complete!
      sum_width = col_widths ? col_widths.reduce(&:+) : 0
      max_width = rows.max_by(&:width)
      [sum_width, max_width].max
    end

    def height
      ensure_complete!
      sum_height = rows.reduce(0) { |a, e| a + e.height }
      [param(:height, 0), sum_height].max
    end

    def incomplete
      rows.none? ? self : find_incomplete_descendant
    end

    def rows
      @rows ||= []
    end

    def add_row(row)
      raise TypeError, "Expected Row, got: #{row.class}" unless row.is_a?(Row)
      row.update_params!(inherited: row_params)
      rows << row
    end

    #
    # The params hash can contain a special :height value
    # It will be used instead of the @row_height when creating the row
    #
    # @param  params [Hash]  row params
    # @return  [Table]  self
    #
    def row(params = {})
      row = Row.new(params.merge(inherited: row_params))
      yield(row)
      rows << row
      self
    end

    def text_row(texts, params = {})
      texts = texts.nil? ? [nil] : Array(texts)
      row(params) { |r| texts.each { |text| r.text_cell(text) } }
    end

    def path_row(path_components, params = {})
      row(params) { |r| r.path_cell(path_components) }
    end

    def polyline_row(points, params = {})
      row(params) { |r| r.polyline_cell(points) }
    end

    def multipolyline_row(strokes, params = {})
      row(params) { |r| r.multipolyline_cell(strokes) }
    end

    def line_row(points, params = {})
      row(params) { |r| r.line_cell(points) }
    end

    def sub_table_row(params = {})
      t = Table.new(params)
      row { |r| r.cell { |c| c.content(t) && yield(t) } }
    end

    def blank_row(params = {})
      raise ArgumentError, ':height required' if !param(:row_height) && !params[:height]
      rows << BlankRow.new(params.merge(inherited: row_params))
      self
    end

    def col_widths
      Table.col_widths(param(:col_widths), param(:width), param(:columns))
    end

    private

    #
    # The dimension overrides given when the table is actually
    # the child of a (parent) table cell.
    # In this case the overrides are used to draw proper borders
    # (since the Cell element of the parent determines its)
    #
    # @param  parent [Rasem::SVGTagWithParent]
    # @param  width_override [Integer]  (optional) container width
    # @param  height_override [Integer]  (optional) container height
    # @return  [Rasem::SVGTagWithParent]
    #
    def _render(parent)
      RasemWrapper.group(parent, class: param(:class), id: param(:id)) do |table_group|
        max_col_widths = rows.map(&:cell_widths).transpose.map(&:max)
        draw_border(table_group)

        rows.reduce(0) do |y, row|
          row.render(table_group, max_col_widths).translate(0, y)
          y + row.height
        end
      end
    end

    def row_params
      param(:row_height)
      return child_params unless param(:row_height)
      child_params.merge(height: param(:row_height))
    end

    def find_incomplete_descendant
      rows.each.with_object(nil) do |row, _|
        res = row.incomplete
        break res if res
      end
    end
  end
end
