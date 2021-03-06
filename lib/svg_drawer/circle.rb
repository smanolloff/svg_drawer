module SvgDrawer
  class Circle < Base
    defaults fill: 'none',
             stroke: 'black',
             size: 1,
             x_reposition: 'none',  # none/left/center/right
             y_reposition: 'none',  # none/top/middle/bottom
             expand: false,
             shrink: false,
             overflow: false,
             scale: 1,
             scale_size: true

    def initialize(center, radius, params = {})
      @center = center
      @radius = radius
      super(params)
    end

    def width
      param(:overflow) ?
        param(:width, calc_width) :
        [param(:width, 0), calc_width].max
    end

    def height
      param(:overflow) ?
        param(:height, calc_height) :
        [param(:height, 0), calc_height].max
    end

    def incomplete
      false
    end

    def min_x
      @min_x ||= @center.first - @radius
    end

    def max_x
      @max_x ||= @center.first + @radius
    end

    def min_y
      @min_y ||= @center.last - @radius
    end

    def max_y
      @max_y ||= @center.last + @radius
    end

    private

    def _draw(parent)
      size = param(:scale_size) ? param(:size) : param(:size) / scale
      style = {}

      # need symbol keys due to a bug in Rasem::SVGTag#write_styles
      style[:fill] = param(:fill)
      style[:stroke] = param(:stroke)
      style[:'stroke-width'] = size

      Utils::RasemWrapper.group(parent, class: 'circle') do |circle_group|
        poly = circle_group.circle(@center.first, @center.last, @radius, style: style.dup)
        poly.translate(translate_x, translate_y).scale(scale, scale)
      end
    end

    def calc_width
      calc_width_unscaled * scale
    end

    def calc_height
      calc_height_unscaled * scale
    end

    def calc_width_unscaled
      max_x - min_x
    end

    def calc_height_unscaled
      max_y - min_y
    end

    def width_unscaled
      param(:overflow) ?
        param(:width, calc_width_unscaled) :
        [param(:width, 0), calc_width_unscaled].max
    end

    def height_unscaled
      param(:overflow) ?
        param(:height, calc_height_unscaled) :
        [param(:height, 0), calc_height_unscaled].max
    end

    def scale
      [scale_x, scale_y].min * param(:scale)
    end

    def scale_x
      return 1 unless param(:width) && (param(:expand) || param(:shrink))
      scale = param(:width).to_d / calc_width_unscaled
      return 1 if (scale > 1 && !param(:expand)) || (scale < 1 && !param(:shrink))
      scale
    end

    def scale_y
      return 1 unless param(:height) && (param(:expand) || param(:shrink))
      scale = param(:height).to_d / calc_height_unscaled
      return 1 if (scale > 1 && !param(:expand)) || (scale < 1 && !param(:shrink))
      scale
    end

    def translate_x
      width_diff = (width - calc_width)

      case param(:x_reposition)
      when 'left' then -min_x * scale
      when 'center' then -min_x * scale + width_diff / 2
      when 'right' then -min_x * scale + width_diff
      when 'none' then 0
      else raise "Bad x_reposition: #{param(:x_reposition)}. Valid are: [left, right, center, none]"
      end
    end

    def translate_y
      height_diff = height - calc_height

      case param(:y_reposition)
      when 'top' then -min_y * scale
      when 'middle' then -min_y * scale + height_diff / 2
      when 'bottom' then -min_y * scale + height_diff
      when 'none' then 0
      else raise "Bad y_reposition: #{param(:y_reposition)}. Valid are: [top, bottom, middle, none]"
      end
    end
  end
end
