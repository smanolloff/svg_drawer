module SvgDrawer
  class Base
    class ElementIncomplete < StandardError
      def initialize(element)
        super("Element incomplete: #{element.inspect}")
      end
    end

    class << self
      attr_reader :required_params, :special_params, :default_params

      #
      # The required_params contain param keys vital to the element.
      # For example, a table can't be initialized without a :columns param.
      # Their values can be provided via inherited_params.
      #
      def requires(*names)
        required_params.concat(names)
      end

      #
      # The special_params contain param keys special to the element.
      # They will not be stored in @child_params
      # See note in #initialize
      #
      def special(*names)
        # Ensure special param are also a valid param (see ParameterMerger#param)
        names_hash = names.map { |n| [n, nil] }.to_h

        # this just Hash#reverse_merge! as implemented in activesupport-4.2
        default_params.merge!(names_hash) { |key, _left, _right| left }
        special_params.concat(names)
      end

      #
      # The default_values is a hash of param values that will be
      # used as a last-resort fallback
      #
      # With and height are applicable to all elements, so they
      # are always included here to avoid "No such param" errors
      # (see ParamMerger#param for details)
      #
      def defaults(hash)
        default_params.update(hash)
      end

      def required_params
        @required_params ||= []
      end

      # These should never be passed down to children
      def special_params
        @special_params ||= %i[id class inherited border borders]
      end

      # Mark these as valid for *all* elements (no default value though)
      def default_params
        @default_params ||= {
          id: nil,
          class: name.demodulize.underscore,
          width: nil,
          height: nil,
          border: nil,
          borders: nil,
          border_style: nil
        }
      end
    end

    attr_writer :width, :height
    attr_reader :params, :inherited_params, :child_params

    #
    # All elements can are initialized with a params hash *only*.
    # This hash contains stuff regular keys like :width, :height, etc.
    # If this hash does *not* contain any of the keys found
    # in self.class.required_params, an error is risen.
    # It may contain an :inherited. Its value is a hash
    # which will serve as a fall-back to any keys not found in the top-level
    # hash.
    # For example:
    # { width: 100, inherited: { width: 200, height: 500 } }
    #
    # Calling #param(:width) on the element will return 100
    # Calling #param(:height) on the element will return 500
    # Calling #param(:foo) will not be found in any of the hashes, so
    # it will be looked up in self.class.default_params:
    #   - if found, will be returned
    #   - if not found, an error will be risen (see ParameterMerger#param)
    #
    # A special @child_params hash is automatically constructed every
    # time #update_params! is called (incl. #initialize)
    # It is a hash that will be passed on as the value of
    # the :inherited key to any child elements constructed.
    # Note that it will not contain any keys found in self.class.special_params
    #
    # Inheritance example:
    #
    #   Table.new(font: 'A') do |table|
    #     table.row do |row|
    #       row.cell do |cell|
    #         cell.content = TextBox.new('foo')      # text 1
    #       end
    #
    #     table.row(font: 'B') do |row|
    #       row.cell do |cell|
    #         cell.content = TextBox.new('foo')      # text 2
    #       end
    #
    #       row.cell(font: 'C') do |cell|
    #         cell.content = TextBox.new('foo')      # text 3
    #       end
    #
    #       row.cell(font: 'C') do |cell|
    #         cell.content(TextBox.new('foo', font: 'D')) # text 4
    #       end
    #     end
    #   end
    #
    # The texts 1, 2, 3 and 4 will have font 'A', 'B', 'C' and 'D'.
    #
    def initialize(params = {})
      @params = {}
      @inherited_params = {}
      @child_params = {}
      @pmerger = Utils::ParameterMerger.new(@params,
                                            @inherited_params,
                                            self.class.default_params)

      update_params!(params)
    end

    # The way to update an element's params
    def update_params!(params)
      @params.update(params.deep_dup)
      @inherited_params.update(@params.delete(:inherited) || {})

      # Note: self.class.default_params is NOT to be merged in @child_params
      @child_params = @inherited_params.merge(@params)
      self.class.special_params.each { |name| @child_params.delete(name) }

      self.class.required_params.each do |rp|
        raise "Required param is missing: #{rp}" unless @pmerger.param?(rp)
      end
    end

    def param(name, default = nil)
      @pmerger.param(name) || default
    end

    def param!(name)
      param(name) or raise "No default value for: #{name}"
    end

    def render(*args)
      ensure_complete!
      _render(*args)
    end

    def ensure_complete!
      pending_element = incomplete
      raise ElementIncomplete, pending_element if pending_element
    end

    #
    # To be defined in subclasses
    #

    def width
      raise NotImplementedError
    end

    def height
      raise NotImplementedError
    end

    def incomplete
      raise NotImplementedError
    end

    private

    def _render(*)
      raise NotImplementedError
    end

    def _complete?
      raise NotImplementedError
    end

    def draw_border(svg)
      borders = param(:borders)
      borders ||= %i[left right top bottom] if param(:border)
      Border.draw(svg, width, height, borders, param(:border_style), param(:class))
    end
  end
end
