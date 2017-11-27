require 'app/lib/utils/text'
require 'active_support/core_ext/string'

module SvgDrawer::Utils
  describe Text do
    # subject { described_class }

    describe '.truncate' do
      it 'does nothing if len <= maxlen' do
        expect(Text.truncate('1234567890', 10)).to eq('1234567890')
      end

      it 'appends ... by default if len > maxlen' do
        expect(Text.truncate('1234567890', 5)).to eq('12...')
      end

      it 'fails is maxlen < trailer.length' do
        expect { Text.truncate('1234567890', 2) }.to raise_error(RuntimeError)
      end
    end

    describe '.word_wrap' do
      it 'considers a char immediately followed by a single delimiter as unseparable' do
        expect(Text.word_wrap('a. b. c', 4)).to eq(['a.', 'b. c'])
        expect(Text.word_wrap('a. b. c', 5)).to eq(['a. b.', 'c'])
        expect(Text.word_wrap('a.b...c', 5)).to eq(['a.b..', '.c'])
      end

      it 'also works with unicode texts' do
        expect(Text.word_wrap('а. бв. г', 4)).to eq(['а.', 'бв.', 'г'])
        expect(Text.word_wrap('а. бв. г', 5)).to eq(['а.', 'бв. г'])
        expect(Text.word_wrap('а.бв...г', 5)).to eq(['а.бв.', '..г'])
      end

      it 'accepts a word pattern' do
        expect(Text.word_wrap('a. b. c', 4, /./)).to eq(['a. b', '. c'])
        expect(Text.word_wrap('a. b. c', 5, /./)).to eq(['a. b.', 'c'])
        expect(Text.word_wrap('a.b...c', 5, /./)).to eq(['a.b..', '.c'])
      end

      it 'wraps on any char if the text contains a word > maxlen' do
        expect(Text.word_wrap('a. b. c. defghijklmnop', 5)).
          to eq(['a. b.', 'c.', 'defgh', 'ijklm', 'nop'])
      end
    end
  end
end
