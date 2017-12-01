# SvgDrawer

A ruby gem to build table-based SVG layouts

<!-- MarkdownTOC -->

- [Installation](#installation)
- [Usage](#usage)
- [Params](#params)
- [Elements](#elements)
  - [Table](#table)
  - [Row](#row)
  - [Cell](#cell)
  - [TextBox](#textbox)
  - [Line](#line)
  - [Polyline](#polyline)
  - [Multipolyline](#multipolyline)
  - [Circle](#circle)
  - [Path](#path)
- [Nesting](#nesting)
- [Configuration](#configuration)
- [Useful shorthands](#useful-shorthands)
- [More examples](#more-examples)
- [Contributing](#contributing)
- [License](#license)

<!-- /MarkdownTOC -->

## Installation

In your Gemfile:

```ruby
gem 'svg_drawer'
```

## Usage

```ruby
# The table with 2 columns
table = SvgDrawer::Table.new(columns: 2, width: 400)

# A row with two text cells
table.row(height: 50) do |row|
  row.cell { |cell| cell.text_box('foo') }
  row.cell { |cell| cell.text_box('bar') }
end

# Another row, with borders
table.row(height: 100, border: true, font_size: 20) do |row|
  row.cell { |cell| cell.text_box('baz') }
  row.cell { |cell| cell.text_box('qux') }
end

# Initialize the image object to draw the table in
img = Rasem::SVGImage.new(width: 600, height: 600)
table.draw(img)

img.to_s
# => "<?xml version=\"1.0\" ..."
```

## Params

Different elements (tables, rows, text boxes, etc.) all accept a set of params when initialized. Usually, each element type accepts a different set of params, listed further below

Many of the params are _inherited_ from the parent element (e.g. if a Table is initialized with a `font` param, it won't use it directly, but child elements (rows) will inherit it, their children (cells) will inherit it, their children (text box) will inherit it).

Regardless of their type, **all** elements share some common params, which are **never** inherited:

|name   |type    |default |strict   |comment |
|:---   |:---    |:---    |:---     |:---    |
|width  |numeric |        |_varies_ |Total element width |
|height |numeric |        |_varies_ |Total element height |
|class  |string  |        |no       |Sets the `class` SVG attribute |
|id     |string  |        |no       |Sets the `id` SVG attribute |

The `strict` column specifies whether the given param value imposes a hard or a soft requirement when drawing.

For the `width` and `height` params, the value is strict only for `TextBox`, `Line`, `Polyline`, `Circle`, `Multipolyline` and `Path`. Basically any element that contains another element treats its `width` and `height` as a _soft_ requirement.

For example:

A table of 1 row and 2 columns can be given a `width` of 100. In the case of a table, this is a _soft_ requirement, it will only be drawn with that width if the cells themselves can fit within that value.

If each of the cells is also given a `width` (say, `80`), then the total table width of 100 above will be exceeded (to a total of 160). In the case of a cell, this is also a _soft_ requirement, as each cell has some content (text box or polyline etc.) that may have its own, different width.

If the two cells each contain polyline with a `width` of `200` and `300`, respectively, then the cells' width of `80` will be ignored (and the total table width becomes `500`). In the case of a polyline, the `width` is a hard requirement and, when given, the elements up in the hierarchy must respect it, i.e. the cell becomes wider (and eventually the table too)

If a `width` is not specified in _any_ of the elements, it will be calculated based on the elements at the bottom of the hierarchy: TextBox, Line, Polyline, Circle, etc. -- their width and height, if not explicitly given, can always be calculated, so the table itself will take as little space as possible, keeping its tabular form.

The below params are shared only by Table, Row and Cell elements and are **never** inherited:

|name         |type          |default                        |comment |
|:---         |:---          |:---                           |:---    |
|borders      |array[string] |`[]`                           |Valid element values: `'top'`, `'bottom'`, `'left'`, `'right'` |
|border       |boolean       |`false`                        |Equivalent to passing all possible values in `borders` |
|border_style |hash          |`{ stroke: 'black', size: 1 }` |Directly mapped to CSS attributes (except for `size`, which is an alias to `stroke-width`) |

## Elements
A high-level overview of the elements:

```
Table                          # Table#rows returns the array of Row objects
└── Row                        # Row#cells returns the array of Cell objects
    └── Cell                   # Cell#content returns the contained object
        ├── TextBox
        ├── Line
        ├── Polyline
        ├── Multipolyline
        ├── Circle
        ├── Path
        └── Table              # an entire new table!
```

Elements are _created_ with a list of [**params**](#params), some of which are mandatory.

Elements become _complete_ when certain criteria are met, usually different for each element type.

Complete elements can be _drawn_ by invoking `#draw` with a single argument -- a [`Rasem`](https://github.com/aseldawy/rasem) SVG object. Usually, one needs to call `#draw` only a the top-level element, which will recursively draw all its child elements too.

### Table

* **Required params**:

|name    |type    |strict |comment |
|:---    |:---    |:---   |:---    |
|columns |integer |yes    |An error is raised unless all rows have exactly this number of cells when `draw` is called|

* **Optional params**:

|name       |type           |default         |strict  |comment |
|:---       |:---           |:---            |:---    |:---    |
|row_height |numeric        |                |no      |default height for rows. Ignored if individual rows specify their height or if their contents can't fit in it |
|col_widths |array[numeric] |`width/columns` |no      |default width for columns. Ignored if individual row cells specify their width or if their contents can't fit in it|

* **Completeness**: Contains at least one row.

##### Examples

* Create a table with two columns. Let the child elements determine width and height:

    ```ruby
    table = SvgDrawer::Table.new(columns: 2)
    ```

* Create a table with 2 columns and a default row height of `100`. Each row will still be able to specify its own, or contain a cell with different height, though:

    ```ruby
    table = SvgDrawer::Table.new(columns: 2, row_height: 100)
    ```

### Row

* **Required params**:

|name    |type    |strict |comment |
|:-------|:-------|:------|:-------|
|columns |integer |yes    |See the [Table](#table) section. Usually inherited from the parent (table)|

* **Optional params**:

|name       |type           |default         |strict  |comment |
|:---       |:---           |:---            |:---    |:---    |
|col_widths |array[numeric] |(width/columns) |no      |See the [Table](#table) section. Usually inherited from the parent (table)|

* **Completeness**: Contains exactly `columns` number of cells.

##### Examples

* Create a row with two columns. Let the child elements determine width and height:
    ```ruby
    row = SvgDrawer::Table.new(columns: 2)
    table.add_row(row)
    ```

* Do the same via the convenient `Table#row` method, inheriting the `columns` param from it:
    ```ruby
      table.row do |row|
        # ...
      end
    ```

### Cell

* Required params: (none)
* Optional params: (none)
* Completeness: Has a content.

##### Examples

* Create a cell with a minimum width of 100 (the contained element, whatever it is, can still expand it):
    ```ruby
    cell = SvgDrawer::Cell.new(width: 100)
    row.add_cell(cell)
    ```

* Do the same via the convenient `Row#cell` method:
    ```ruby
      row.cell do |cell|
        # ...
      end
    ```

### TextBox

In contrast to the Table, Row and Cell elements, this element expects an argument to `#initialize`: the string to draw. Second come the params.

Also, the _strict_ column below is omitted, as all params are considered strict (a text box is at the bottom of the element hierarchy and has no children). Exceptions to that rule are explicitly stated otherwise.

It is also always _complete_, as the only requirement is to have a text to draw, which is a mandatory argument to `initialize` anyway.

The text itself will be wrapped on multiple lines if the width is restricted (by having a fixed `width`, either inherited or set explicitly). The `height` is not strict, because a text can't be vertically restricted -- it either wraps on as many lines as needed, or is always drawn on a single line (there is no `width` restriction, or `overflow` and/or `truncate` params are given)

* **Required params**: (none)
* **Optional params**:

|name          |type          |default                                    |comment |
|:---          |:---          |:---                                       |:---    |
|font          |string        |`'Courier New'`                            |Font name|
|font_style    |array[string] |`[]`                                       |Valid element values: `'bold'`, `'italic'`|
|font_weight   |numeric       |`400`                                      |More means **bolder**. Ignored if `font_style` is also given and contains `'bold'`|
|font_size     |_varies_      |`12`                                       |If given value is numeric, then size is in `px`. Alternatively, string values such as `'1em'` or `'8pt'` are also valid|
|font_color    |string        |`'black'`                                  ||
|text_align    |string        |`'left'`                                   |Valid values: `'left'`, `'right'`, `'center'`|
|text_valign   |string        |`'bottom'`                                 |Valid values: `'top'`, `'bottom'`, `'middle'`|
|line_height   |numeric       |`1`                                        |Determines vertical spacing when text is wrapped into multiple lines|
|wrap_policy   |string        |`'normal'`                                 |Valid values: `'weak'`, `'normal'`, `'aggressive'`, `'max'`. More information in the [Configuration](#configuration) section|
|word_pattern  |regexp        |(see below)                                |Pattern that will be used to extract words from the text (whatever matches will never be wrapped unless it alone exceeds the total line length)|
|overflow      |boolean       |`false`                                    |When `true`, wrapping will not occur and all text will be drawn on one line, possibly exceeding the element width, but without affecting it. Ignored if there is no width restrictions|
|truncate      |boolean       |`false`                                    |Same as `overflow`, but the text will be truncated at the element width. Ignored if `overflow` is also true|
|truncate_with |string        |`'...'`                                    |The string to append to the truncated text|
|text_padding  |hash          |`{ top: 0, bottom: 0, left: 0, right: 0 }` |Extra spacing at the sides of the text box|

The word pattern is a regexp that tries to match either a word, or a word followed by a single delimiter -- this helps word wrap to avoid moving a `.` at the end of a sentence to a new line. This pattern can surely be improved, but it looks sufficient for now:

```
/[[:word:]]+[^[:word:]]\s?(?![^[:word:]])|[[:word:]]+|[^[:word:]]/
```

Contains exactly `columns` number of cells.

* **Completeness**: Always.

##### Examples

* Create text box with a fixed width. If the text does not fit on one line with that width, let it overflow without chaning the tabular structure (i.e. _pretend_ that width is `100`):
    ```ruby
    text_box = SvgDrawer::TextBox.new("Lorem ipsum", width: 100, overflow: true)
    cell.content(text_box)
    ```

* Do the same via the convenient `Cell#text_box` method:
    ```ruby
      cell.text_box('foo bar', width: 100, overflow: true)
    ```

### Line

Similar to the TextBox, this element expects an argument to #initialize: an array of exactly 4 numeric values ([start_x, start_y, end_x, end_y]). Second come the params.

* **Required params**: (none)
* **Optional params**:

|name          |type     |default   |comment |
|:---          |:---     |:---      |:---    |
|stroke        | string  |`'black'` |Line color |
|linecap       | string  |`'butt'`  |Line ending style (see the SVG `stroke-linecap` attribute) |
|size          | numeric |`1`       |Line size (or line width) |
|x_reposition  | string  |`'none'`  |Transpose the line (i.e. if points are [40,20,30,40], a `left` align will change them to [10,20,0,40])|
|y_reposition  | string  |`'none'`  |Same as x_reposition, but for vertical alignment|
|expand        | boolean |`false`   |Scale the element up to a fixed width and/or height, maintaining aspect ratio. Ignored if neither `width` nor `height` are also given|
|shrink        | boolean |`false`   |Same as `expand`, but scale the element down to ensure it completely fits|
|dotspace      | numeric |`0`       |When greater than 0, draw a dotted line instead, the value being the space between the dots|
|overflow      | boolean |`false`   |Ignore any width and/or height restrictions and draw freely. Ignored if `expand` and/or `shrink` are given|
|scale         | numeric |`1`       |Manually scale the element. If `shrink` and/or `expand` are also given, apply `scale` after them|
|scale_size    | boolean |`true`    |When `true`, scaling/expanding/shrinking will also change the line size proportionally|

* **Completeness**: Initialized with exactly two coordinates (star and end point)

##### Examples

* Create a line that is scaled down to fit a 100x100 box:
    ```ruby
    line = SvgDrawer::Line.new([0, 0, 300, 50], width: 100, height: 100, shrink: true)
    cell.content(line)
    ```

* Do the same via the convenient `Cell#line` method. It will be shrinked until it fits the cell's boundaries, if any, otherwise it will be drawn full-size:
    ```ruby
      cell.line([0, 0, 300, 50], shrink: true)
    ```

### Polyline

A polyline behaves just like the line, but can be initialized with more than 4 elements in the array.

* **Required params**: (none)
* **Optional params**: Same as for `Line`, with two more:

|name          |type     |default   |comment |
|:---          |:---     |:---      |:---    |
|linejoin      | string  |`'miter'` |Line joint style (see the SVG `stroke-linejoin` attribute) |
|fill          | string  |`'none'`  |Coloring of the _inner_ area of the polyline |

* **Completeness**: Initialized with two or more coordinates

##### Examples

* Create a polyline using the `Cell#polyline` shorthand:
    ```ruby
      cell.polyline([0, 0, 300, 50, 20, 74, 244, 124])
    ```

### Multipolyline

Same as polyline, but initialized with a 2-dimension array (each array representing a polyline)

This is useful mostly when a combination of polylines needs to be drawn, which all scale proportionally, as one, to fit a given container.

Note: one can always use `Multipolyline` instead of a `Polyline`, as it builds on top of it -- in the end, it is a matter of personal taste.

* **Required params**: (none)
* **Optional params**: Same as for `Polyline`
* **Completeness**: Any of the nested polylines is not complete

##### Examples

* Create a multipolylines using the `Cell#multipolyline` shorthand:
    ```ruby
      cell.multipolyline([0, 0, 300, 50, 20, 74, 244, 124])
    ```

### Circle

This element expects _two_ arguments to `#initialize`: an array of exactly 2 numeric values ([x, y]) and a radius. Third come the params.

* **Optional params**:

|name          |type     |default   |comment |
|:---          |:---     |:---      |:---    |
|fill          | string  |`'none'`  |Coloring of the _inner_ area of the circle |
|stroke        | string  |`'black'` |Circle outline color |
|size          | numeric |`1`       |Circle outline size |
|x_reposition  | string  |`'none'`  |see [Line](#line)|
|y_reposition  | string  |`'none'`  |see [Line](#line)|
|expand        | boolean |`false`   |see [Line](#line)|
|shrink        | boolean |`false`   |see [Line](#line)|
|overflow      | boolean |`false`   |see [Line](#line)|
|scale         | numeric |`1`       |see [Line](#line)|
|scale_size    | boolean |`true`    |see [Line](#line)|

* **Completeness**: Always

##### Examples

* Create a circle that is scaled down to fit a 100x100 box:
    ```ruby
    line = SvgDrawer::Circle.new([0, 50], 300, width: 100, height: 100, shrink: true)
    cell.content(line)
    ```

* Do the same via the convenient `Cell#circle` method. It will be shrinked until it fits the cell's boundaries, if any, otherwise it will be drawn full-size. Also re-position the circle in the container's center:
    ```ruby
      cell.line([0, 0, 300, 50], shrink: true, x_reposition: 'center', y_reposition: 'middle')
    ```

### Path

The Path element expects an array of strings, each representing a list of path commands.

This is the most restricted element in SvgDrawer -- it does not support repositioning, expanding and/or shrinking, it is basically always drawn as-is. This is because it is *very* hard to compute the element's boundary coordinates and, without those, no useful transformations can be applied here.

For that reason, `width` and `height` are **required** params, as they can't be calculated based on the contents.

##### Examples

* Create a path (width and height are needed by the parent element to know how to draw its contents):
    ```ruby
    cell.path(['M859.6,53.59a20.3,20.3,0,1,0,20.29,20.3'], width: 8, height: 8)
    ```

## Nesting

Nesting is supported -- a cell's content can be an entirely new table:

```ruby
table = SvgDrawer::Table.new(columns: 2)

table.row do |row|
  row.cell do |cell|
    sub_table = SvgDrawer::Table.new(columns: 4)
    # add rows, cells to sub_table
    # ...
    # then set the sub_table as the content of the parent table's cell
    cell.content(sub_table)
  end
end
```

## Configuration

Calling `SvgDrawer.configuration` will return the current fonts configuration in use.

It can be updated with

```ruby
config = YAML.load_file('svg_drawer.yml')
SvgDrawer.configuration.update(config)
```

The configuration file has the following structure:

```yaml
Arial:
  width: 0.63         # (average) width in px of a font letter at font size 1
  height: 1.3         # (average) height in px of a font letter at font size 1
  y_offset: 0.23      # how much to "lift" the text
  wrap_policies:
    weak: 0.9             # english text with very occasional capitals
    normal: 1             # randomly mixed small/capital chars
    aggressive: 1.17      # capital chars
    max: 1.85             # capital "W" (widest english char in Arial)
```

Configuring a non-monospace font is extremely tricky, provided that every client renders fonts differently, so it is recommended to use monospace fonts only.

`y_offset` is also calculated experimentally with chrome inspector. It is needed because, as opposed to HTML, in SVG, when a text is drawn, it is _transposed_ down by (1.2 * [font_height]) px. This causes problems when drawing a text box with a border, as letters like `g` or `p` will intersect with the bottom border (and `_` will even be drawn entirely below the border). This is compensated with the y_offset, which seems to be ~0.22 and usually does OK for all fonts I have tested so far.

Any value that is not found in the font's config is taken from the default font configuration, which seems good for most monospaced fonts:

```yaml
default:
  width: 0.63
  height: 1.2
  y_offset: 0.23
  wrap_policies:
    weak: 1
    normal: 1
    aggressive: 1
    max: 1
```

The default configuration file can be found [here](/lib/fonts.yml)

## Useful shorthands

As already pointed out, there are methods are not required, but that make it slightly work with SvgDrawer.

They are:

* `Table#row`
* `Table#blank_row` (useful for as a "spacer" row in a table with a fixed height)
* `Table#text_row` (can accept an array of strings, one for each cell)
* `Table#path_row`
* `Table#line_row`
* `Table#polyline_row`
* `Table#multipolyline_row`
* `Table#circle_row`
* `Row#cell`
* `Row#text_cell`
* `Row#path_cell`
* `Row#line_cell`
* `Row#polyline_cell`
* `Row#multipolyline_cell`
* `Row#circle_cell`
* `Cell#text_box`
* `Cell#path`
* `Cell#line`
* `Cell#polyline`
* `Cell#multipolyline`
* `Cell#circle`

For example, to create a simple table with only text boxes, all formated the same way, one can combine the inheritance mechanism and these shorthands and do this:

```ruby
t = Table.new(columns: 3, width: 300, row_height: 50, text_align: 'center', text_valign: 'middle', font_size: 16)
t.text_row(['foo', 'bar', 'baz'])
t.text_row(['qux', 'fred', 'thud'])
t.text_row(['wibble', 'wobble', 'wubble'])
```

Result [here](doc/examples/shortcuts.svg)

## More examples

See the [examples](doc/examples) directory for moar

A real-world example: at SumUp, we generate SVG receipts which we then convert to PNG before printing [receipt](doc/examples/receipt.png) for a transaction made with SumUp card reader.

## Known limitations

* Text is rendered with different size on different viewers, which causes problems with text wrapping. As opposed to HTML, automatic text wrapping is not possible with SVG, so the text is wrapped manually at generation time, by calculating the its width based on the config values. However, different viewers render text differently, and you might end up with your text looking fine on one viewer and completely wrong on another viewer. 
* support for path elements is super limited -- you can't scale them up, down, or reposition them.
* if two cells in a row have different heights, their borders will be drawn at different heights, making the table layout look weird. The table layout is still Ok, though, if you don't draw cell borders at all. It is questionable if that is actually a feature, or a limitation, anyway, maybe in some future version it will can be made configurable.
* some SVG attributes are not supported (there is no corresponding param for them). This can usually be easily resolved if there is a need for that.

## Contributing

1. Fork it
2. Create your feature branch
3. Comply with the [ruby style guide](https://github.com/bbatsov/ruby-style-guide)
4. Try to add tests for your new feature/bugfix. Given I haven't written any thus far :) I can't put a hard requirement on this.
5. Submit a pull request

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
