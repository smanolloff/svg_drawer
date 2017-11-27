module Utils
  module SVG
    module RasemWrapper
      module_function

      %i[group rect text].each do |n|
        define_method(n) do |svg_ctx, params = {}, &b|
          svg_ctx.public_send(n, params.compact) { b.call(self) if b }
        end
      end
    end
  end
end
