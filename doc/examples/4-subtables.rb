require 'bundler/setup'
require 'svg_drawer'

table = SvgDrawer::Table.new(columns: 2, font: 'Courier New')

table.row do |row|
  row.cell do |cell|
    subtable = SvgDrawer::Table.new(columns: 3, )
    subtable.row do |subrow|
      subrow.cell { |subcell| subcell.text_box('subcell') }
      subrow.cell { |subcell| subcell.text_box('subcell') }
      subrow.cell { |subcell| subcell.text_box('subcell') }
    end
    subtable.row do |subrow|
      subrow.cell { |subcell| subcell.text_box('subcell') }
      subrow.cell { |subcell| subcell.text_box('subcell') }
      subrow.cell { |subcell| subcell.text_box('subcell') }
    end

    cell.content(subtable)
  end

  row.cell do |cell|
    cell.text_box('parent cell')
  end
end

table.row do |row|
  row.cell do |cell|
    cell.text_box('parent cell')
  end

  row.cell do |cell|
    subtable = SvgDrawer::Table.new(columns: 3, )
    subtable.row do |subrow|
      subrow.cell { |subcell| subcell.text_box('subcell') }
      subrow.cell { |subcell| subcell.text_box('subcell') }
      subrow.cell { |subcell| subcell.text_box('subcell') }
    end

    cell.content(subtable)
  end
end

res = Rasem::SVGImage.new(width: 900, height: 1600)
table.draw(res).translate(10, 10)
File.write(File.basename(__FILE__, '.rb') + '.svg', res.to_s)
