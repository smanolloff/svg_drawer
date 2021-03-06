require 'bundler/setup'
require 'svg_drawer'

table = SvgDrawer::Table.new(columns: 3, border: true, font: 'Courier New')

table.row(border: true) do |row|
  row.cell(border: true) do |cell|
    cell.text_box("A text with unset width will span as long as needed")
  end

  row.cell(width: 200, border: true) do |cell|
    cell.text_box('A text with fixed width will wrap on a delimiter. Extra    spacing    is removed.   ')
  end

  row.cell(width: 100, border: true) do |cell|
    cell.text_box('VeryLongWordsAreWrappedOnAnyCharacterByDefault')
  end
end

table.row(border: true) do |row|
  row.cell(width: 100, border: true) do |cell|
    cell.text_box('A single delimiter following a word is not wrapped on its own. Example: wrap this. wrapp this.')
  end

  row.cell(width: 200, border: true) do |cell|
    cell.text_box('Truncation is also an option', truncate: true)
  end

  row.cell(width: 200, border: true) do |cell|
    cell.text_box('Overflow ignores any width restrictions', overflow: true)
  end

end

res = Rasem::SVGImage.new(width: 900, height: 500)
table.draw(res).translate(10, 10)
File.write(File.basename(__FILE__, '.rb') + '.svg', res.to_s)
