require 'bundler/setup'
require 'svg_drawer'

table = SvgDrawer::Table.new(columns: 3, width: 300, row_height: 50, text_align: 'center', text_valign: 'middle', font_size: 16, border: true)

table.text_row(['foo', 'bar', 'baz'], border: true)
table.text_row(['qux', 'fred', 'thud'], border: true)
table.text_row(['wibble', 'wobble', 'wubble'], border: true)

res = Rasem::SVGImage.new(width: 900, height: 1600)
table.draw(res).translate(10, 10)
File.write(File.basename(__FILE__, '.rb') + '.svg', res.to_s)
