module SvgDrawer
  module Utils
    module RasemWrapper
      module_function

      %i[group rect text].each do |n|
        define_method(n) do |svg_ctx, params = {}, &b|
          compact_params = params.reject { |_k, v| v.nil? }
          svg_ctx.public_send(n, compact_params) { b.call(self) if b }
        end
      end
    end
  end
end
