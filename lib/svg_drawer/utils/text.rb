module SvgDrawer
  module Utils
    module Text
      module_function

      DEFAULT_WORD_PATTERN = /
        [[:word:]]+         # chars
        [^[:word:]]         # delimiter
        \s?                 # optional space
        (?![^[:word:]])     # not followed by delimiter
        |
        [[:word:]]+         # chars
        |
        [^[:word:]]         # delimiter
      /x

      def truncate(text, maxlen, trailer = '...')
        return text unless text.length > maxlen
        raise if maxlen < trailer.length
        text.slice(0, maxlen - trailer.length).concat(trailer)
      end

      #
      # Wrap on any word delimiter, but consider a word followed
      # by a single delimiter and a space as unwrappable (e.g. end of sentence)
      #
      # If word itself is longer than max line length, force-wrap it
      # on any char (effectively slicing it at maxlen)
      #
      def word_wrap(txt, maxlen, word_pattern = DEFAULT_WORD_PATTERN)
        words = txt.scan(word_pattern)

        words.each_with_object(['']) do |word, lines|
          last = lines.last
          wordlen = word.rstrip.length

          if wordlen > maxlen
            lines.concat(word.scan(/.{1,#{maxlen}}/))
          elsif last != '' && last.length + wordlen > maxlen
            lines << word
          else
            lines.last << word
          end
        end.delete_if(&:empty?).each(&:strip!)
      end

      # def word_wrap(txt, max_chars, word_delimiter = /\b/)
      #   words = txt.squish.split(word_delimiter)

      #   words.each_with_object(['']) do |word, lines|
      #     last = lines.last
      #     lines << '' if last != '' && last.length + word.length > max_chars
      #     lines.last << word
      #   end.each(&:strip!)
      # end

      # def word_wrap(txt, maxlen, delimiter = ' ')
      #   words = txt.squish.split(delimiter)

      #   words.each_with_object(['']) do |word, lines|
      #     last = lines.last
      #     lines << '' if last != '' && last.length + word.length > maxlen
      #     lines.last << word
      #   end.each(&:strip!)
      # end
    end
  end
end
