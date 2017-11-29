module SvgDrawer
  class TextBox < Base
    defaults font: 'Courier New',
             font_style: [],
             font_weight: 400,
             font_size: 12,
             font_color: 'black',
             text_align: 'left',
             text_valign: 'bottom',
             line_height: 1,
             wrap_policy: 'normal',
             word_pattern: /[[:word:]]+[^[:word:]]\s?(?![^[:word:]])|[[:word:]]+|[^[:word:]]/,
             overflow: false,
             truncate: false,
             truncate_with: '...',
             text_padding: { top: 0, bottom: 0, left: 0, right: 0 }

    def initialize(text, params = {})
      super(params)
      @text = text.to_s.strip.gsub(/\s+/, ' ')
      fonts_config = SvgDrawer.configuration
      @config = fonts_config['default'].merge(fonts_config[param(:font)] || {})
    end

    def width
      return @width if @width
      ensure_complete!
      @width = param(:width, calculate_width).to_d
    end

    # If overflow is true, but we don't have any explicit height set,
    # report the calculated height.
    def height
      return @height if @height
      ensure_complete!
      @height = param(:overflow) ?
        param(:height, calculate_height).to_d :
        [param(:height, 0), calculate_height].max.to_d
    end

    def incomplete
      false
    end

    private

    def _draw(parent)
      # need symbol keys due to a bug in Rasem::SVGTag#write_styles
      style = {}
      style[:fill] = param(:font_color)
      style[:'font-family'] = param(:font)
      style[:'text-anchor'] = align_to_anchor(param(:text_align))
      style[:'font-weight'] = param(:font_style).include?('bold') ? 'bold' : param(:font_weight)
      style[:'font-style'] = 'italic' if param(:font_style).include?('italic')
      style[:'font-size'] = param(:font_size).is_a?(Numeric) ?
        "#{param(:font_size)}pt" :
        param(:font_size)

      svg_params = { x: 0, y: 0, style: style }

      case param(:text_align)
      when 'left' then svg_params[:x] += param(:text_padding)[:left]
      when 'right' then svg_params[:x] += width - param(:text_padding)[:right]
      when 'center' then svg_params[:x] += width.to_d / 2
      end

      y_deltas = calculate_y_deltas

      Utils::RasemWrapper.group(parent, class: param(:class)) do |text_box_group|
        root_y = svg_params[:y]

        draw_border(text_box_group)
        lines.zip(y_deltas).each do |line, delta_y|
          svg_params[:y] = root_y + delta_y
          escaped = line.encode(xml: :text)
          Utils::RasemWrapper.text(text_box_group, svg_params) { |txt| txt.raw(escaped) }
        end
      end
    end

    def align_to_anchor(align)
      case align
      when 'left' then 'start'
      when 'right' then 'end'
      when 'center' then 'middle'
      else raise "Bad text_align: #{align}. Valid are: [left, right, center]"
      end
    end

    def font_width_px
      @config['width']
    end

    def font_height_px
      @config['height']
    end

    def calculate_line_height_px
      font_height_px * param(:font_size) * param(:line_height)
    end

    def calculate_y_offset_px
      font_height_px * param(:font_size) * @config['y_offset']
    end

    def lines
      return [@text] if param(:overflow)
      txt = param(:truncate) ?
        Utils::Text.truncate(@text, chars_per_line, param(:truncate_with)) :
        @text

      Utils::Text.word_wrap(txt, chars_per_line, param(:word_pattern))
      # Text.word_wrap(txt, chars_per_line, /\b/)
    end

    def chars_per_line
      font_width = font_width_px.to_d * param(:font_size)
      font_wrap_policy = @config['wrap_policies']
      wrap_coeff = font_wrap_policy[param(:wrap_policy)]
      adj_font_width = font_width * wrap_coeff
      xpad = param(:text_padding)[:left] + param(:text_padding)[:right]
      ((width - xpad) / adj_font_width).to_i
    end

    def calculate_width
      font_width = font_width_px * param(:font_size)
      @text.length * font_width
    end

    def calculate_height
      return 0 if @text.empty?
      ypad = param(:text_padding)[:top] + param(:text_padding)[:bottom]
      ypad + lines.size * calculate_line_height_px
    end

    def calculate_y_deltas
      lheight = calculate_line_height_px
      yoffset = calculate_y_offset_px
      base_deltas = 1.upto(lines.size).map { |lineno| lineno * lheight - yoffset }
      remaining_height = height - calculate_height

      case param(:text_valign)
      when 'top'
        base_deltas.map { |bd| bd + param(:text_padding)[:top] }
      when 'bottom'
        base_deltas.map { |bd| bd + remaining_height }
      when 'middle'
        base_deltas.map { |bd| bd + remaining_height / 2 }
      else raise "Bad text_valign: #{param(:text_valign)}. Valid are: [top, bottom, middle]"
      end
    end
  end
end
