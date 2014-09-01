module RomanNumerals
  class RomanNumeral
    ConversionError = Class.new(RuntimeError)

    ARABIC_TO_ROMAN_MAP = {
      1    => "I",
      4    => "IV",
      5    => "V",
      9    => "IX",
      10   => "X",
      40   => "XL",
      50   => "L",
      90   => "XC",
      100  => "C",
      400  => "CD",
      500  => "D",
      900  => "CM",
      1000 => "M"
    }
    ROMAN_TO_ARABIC_MAP = ARABIC_TO_ROMAN_MAP.invert
    ROMAN_CHUNK_REGEX   = Regexp.new(
      "(?:" +                                        # a non-capturing group
      ROMAN_TO_ARABIC_MAP                            # made of the keys above
        .keys
        .sort_by { |chunk| -chunk.chars.uniq.size }  # sort two char types first
        .join("|") +                                 # join with regex OR
      ")"                                            # end group
    )

    def self.from_i arabic_number
      fail ConversionError, "Cannot convert #{arabic_number}" \
        unless (1..3999).include?(arabic_number)

      ARABIC_TO_ROMAN_MAP.keys.sort.reverse.inject("") {|roman_return_string,key|
        multiplier,arabic_number = arabic_number.divmod(key)
        roman_return_string += ARABIC_TO_ROMAN_MAP[key] * multiplier
      }
    end

    def self.convert value
      roman_numeral = new(value)
      if roman_numeral.valid?
        roman_numeral.to_i
      else
        from_i(value.to_i)
      end
    end

    def initialize(numeral)
      @numeral = numeral
    end

    attr_reader :numeral
    private     :numeral

    def valid?
      numeral.is_a?(String) && only_roman_digits? &&
                               roman_digits_in_order? &&
                               all_roman_characters_less_than_three?
    end

    def to_i
      fail ConversionError, "Cannot convert #{roman_number}" unless valid?

      chunks.inject(0, :+)
    end

    private

    def chunks
      Enumerator.new do |yielder|
        numeral.scan(/\G#{ROMAN_CHUNK_REGEX}/) do |chunk|
          yielder.yield ROMAN_TO_ARABIC_MAP[chunk]
        end
      end
    end

    def only_roman_digits?
      remainder= numeral.dup
      ARABIC_TO_ROMAN_MAP.each_value {|value| remainder.delete!(value) }
      !(remainder.size > 0 )
    end

    def roman_digits_in_order?
      chunks.each_cons(2).all? { |a| a[0] >= a[1] }
    end

    def all_roman_characters_less_than_three?
      (ARABIC_TO_ROMAN_MAP.values.select {|n| n.size==1}).each.all?  { |ch|
                                   ! numeral.include?(ch * 4) }
    end
  end
end
