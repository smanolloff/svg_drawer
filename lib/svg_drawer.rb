require 'bigdecimal'
require 'bigdecimal/util'
require 'rasem'
require 'yaml'

module SvgDrawer
  class << self
    attr_reader :configuration
  end

  config_file = File.join(File.dirname(__FILE__), 'fonts.yml')
  @configuration = YAML.load_file(config_file)
end

require 'svg_drawer/version'
require 'svg_drawer/utils/text'
require 'svg_drawer/utils/parameter_merger'
require 'svg_drawer/utils/rasem_wrapper'
require 'svg_drawer/base'
require 'svg_drawer/text_box'
require 'svg_drawer/polyline'
require 'svg_drawer/multipolyline'
require 'svg_drawer/line'
require 'svg_drawer/path'
require 'svg_drawer/circle'
require 'svg_drawer/image'
require 'svg_drawer/table/cell'
require 'svg_drawer/table/blank_row'
require 'svg_drawer/table/row'
require 'svg_drawer/table/table'
require 'svg_drawer/table/border'

