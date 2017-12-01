require 'bundler/setup'
require 'svg_drawer'

border = true

res = Rasem::SVGImage.new(width: 600, height: 600)
t = SvgDrawer::Table.new(columns: 3)

t.row do |row|
  row.cell(width: 160, height: 160, border: border) do |cell|
    cell.text_box('this is some text', font: 'Courier New',
                                       font_color: 'red',
                                       font_size: 12,
                                       font_style: ['bold'],
                                       text_align: 'center',
                                       text_valign: 'middle')
  end

  row.cell(width: 160, height: 160, border: border) do |cell|
    cell.line([5,40,400,80], stroke: 'red', size: 6, shrink: true)
  end

  row.cell(width: 160, height: 160, border: border) do |cell|
    cell.circle([0,0], 30, fill: 'green', x_reposition: 'center')
  end
end


t.row do |row|
  row.cell(width: 160, height: 160, border: border) do |cell|
    cell.polyline([10,10,40,120,150,150,10,150,10,10], fill: 'yellow',
                                                       stroke: 'blue',
                                                       size: 4,
                                                       dotspace: 4,
                                                       linecap: 'round')
  end

  row.cell(width: 160, height: 160, border: border) do |cell|
    elem = [20,20,80,40,20,60]
    points = [elem, elem.map { |x| x + 60 }.shuffle]

    cell.multipolyline(points, stroke: 'blue', size: 2)
  end

  row.cell(width: 160, height: 160, border: border) do |cell|
    points = [
      'M859.6,53.59a20.3,20.3,0,1,0,20.29,20.3',
    ]

    cell.path(points, scale: [0.18, 0.18])
  end
end

t.draw(res, debug: true)
File.write(File.basename(__FILE__, '.rb') + '.svg', res.to_s)
