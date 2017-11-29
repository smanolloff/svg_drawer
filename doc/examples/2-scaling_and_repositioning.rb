require 'bundler/setup'
require 'svg_drawer'

res = Rasem::SVGImage.new(width: 700, height: 1600)
t = SvgDrawer::Table.new(columns: 3, border: true)

points = [0,0,5,50,10,0,15,50,20,0,25,50]
text_cell_params = { width: 200, height: 60, border: true, border_style: { size: 2 }, text_align: 'center', text_valign: 'bottom' }
polyline_cell_params = { width: 200, height: 200, border: true }

rows = [
  [
    {},
    { x_reposition: 'center', y_reposition: 'middle' },
    { x_reposition: 'right', y_reposition: 'bottom' }
  ],
  [
    { expand: true },
    { expand: true, scale_size: false },
    { scale: 3 }
  ],
  [
    { expand: true, dotspace: 2 },
    { expand: true, dotspace: 2, linecap: 'round' },
    { expand: true, dotspace: 15, linecap: 'round' }
  ],
  [
    { expand: true, size: 5 },
    { expand: true, size: 5, linecap: 'round' },
    { expand: true, size: 5, linecap: 'round', x_reposition: 'left', y_reposition: 'top' }
  ]
]

rows.each do |cells|
  t.row do |row|
    cells.each do |params|
      row.cell(text_cell_params) { |cell| cell.text_box(params.to_s) }
    end
  end

  t.row do |row|
    cells.each do |params|
      row.cell(polyline_cell_params) { |cell| cell.polyline(points, params) }
    end
  end
end

t.draw(res).translate(10, 10)
File.write(File.basename(__FILE__, '.rb') + '.svg', res.to_s)
