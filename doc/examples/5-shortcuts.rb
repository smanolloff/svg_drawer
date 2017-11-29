require 'bundler/setup'
require 'svg_drawer'

table = SvgDrawer::Table.new(columns: 2, col_widths: [150, 150], font: 'Courier New')

table.text_row(['foo', 'bar'], font_style: ['bold'], font_size: 16, border: true)
table.text_row(['baz', 'qux'], font_style: ['italic'], font_size: 18, border: true)

points = 10.times.reduce([]) { |a, i| a += [i * 10, (i % 2) * 10] }

table.row(border: true) do |row|
  row.polyline_cell(points)
  row.polyline_cell(points)
end

res = Rasem::SVGImage.new(width: 900, height: 300)
table.draw(res).translate(10, 10)
File.write(File.basename(__FILE__, '.rb') + '.svg', res.to_s)
