module Utils
  module SVG
    class Group < Base
      def width
        ensure_complete!
        [param(:width, 0), elements.max_by(&:width).max].max
      end

      def height
        ensure_complete!
        [param(:height, 0), elements.map(&:height).sum].max
      end

      def incomplete
        elements.any? ? self : find_incomplete_descendant
      end

      def elements
        @elements ||= []
      end

      def element(elements)
        raise TypeError, 'All elements must to respond to #render' unless el.all? { |e| e.respond_to?(:render) }
        elements.each { |el| el.update_params!(inherited: child_params) }
        elements << element
      end

      private

      def _render(parent)
        RasemWrapper.group(parent, class: param(:class), id: param(:id)) do |cell_group|
          draw_border(cell_group)
          @content.render(cell_group)
        end
      end

      def find_incomplete_descendant
        elements.each.with_object(nil) do |row, _|
          res = row.incomplete
          break res if res
        end
      end
    end
  end
end
