module SvgDrawer
  class Polyline < Base
    # NOTE: reposition and scale behaviors can be moved to Base
    #       but that is not needed at the moment
    #
    # :expand ensures that if the elem is smaller than the given dimensions,
    # it will be scaled *up* until its either X or Y dim hits the bounds
    # :shrink is similar, but scales the element *down* until both X and Y
    # dim fit within the bounds
    #
    # If either :expand or :shrink are given, :overflow is ignored
    #
    # :scale_size is taken into account only if :shrink and/or :expand are
    # given, and determines whether the given size (i.e. stroke-width) is
    # also scaled accordingly
    #
    # :dotspace, if given, will cause the line to become dotted
    #
    defaults fill: 'none',
             stroke: 'black',
             linecap: 'butt',
             linejoin: 'miter',
             size: 1,
             x_reposition: 'none',  # none/left/center/right
             y_reposition: 'none',  # none/top/middle/bottom
             expand: false,
             shrink: false,
             dotspace: 0,
             overflow: false,
             scale: 1,
             scale_size: true

    def initialize(points, params = {})
      @points = points
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
      @points.size < 4 || @points.size.odd? ? self : nil
    end

    def min_x
      @min_x ||= @points.each_slice(2).min_by(&:first).first - cap_size
    end

    def max_x
      @max_x ||= @points.each_slice(2).max_by(&:first).first + cap_size
    end

    def min_y
      @min_y ||= @points.each_slice(2).min_by(&:last).last - cap_size
    end

    def max_y
      @max_y ||= @points.each_slice(2).max_by(&:last).last + cap_size
    end

    private

    def _draw(parent)
      size = param(:scale_size) ? param(:size) : param(:size) / scale
      dotspace = param(:scale_size) ? param(:dotspace) : param(:dotspace) / scale
      dotsize = size
      style = {}

      if param(:linecap).eql?('round')
        dotsize = 0
        dotspace *= 2
      end

      # need symbol keys due to a bug in Rasem::SVGTag#write_styles
      style[:fill] = param(:fill)
      style[:stroke] = param(:stroke)
      style[:'stroke-width'] = size
      style[:'stroke-linecap'] = param(:linecap)
      style[:'stroke-linejoin'] = param(:linejoin)
      style[:'stroke-dasharray'] = "#{dotsize}, #{dotspace}" if dotspace > 0

      Utils::RasemWrapper.group(parent, class: 'polyline') do |polyline_group|
        poly = polyline_group.polyline(@points, style: style.dup)
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

    def cap_size
      param(:size).to_d / 2
    end
  end
end
