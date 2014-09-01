module RomanNumerals
  class RomanNumeral
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

    def initialize
    end

    def to_roman arabic_number
      return false unless is_arabic? arabic_number
      to_roman_private arabic_number.to_i
    end

    def to_arabic roman_number
      return false unless is_roman? roman_number
      roman_split(roman_number).inject(0) {|result,element|  result + element }
    end

    def convert value
      to_roman(value) || to_arabic(value) || "invalid entry"
    end

    private

    def is_arabic? number
      return (1..3999).include?(number.to_i)
    end

    def roman_split roman_number
      returnme = []
      roman_each(roman_number) {|numeral| returnme  << numeral   }
      returnme
    end

    def roman_each roman_numeral, &block
      roman_numeral.scan(/\G#{ROMAN_CHUNK_REGEX}/) do |chunk|
        yield ROMAN_TO_ARABIC_MAP[chunk]
      end
    end

    def only_roman_digits? roman_number
      remainder= roman_number.dup
      ARABIC_TO_ROMAN_MAP.each_value {|value| remainder.delete!(value) }
      !(remainder.size > 0 )
    end

    def roman_digits_in_order? roman_number
      roman_split(roman_number).each_cons(2).all? { |a| a[0] >= a[1] }
    end

    def all_roman_characters_less_than_three? character
      (ARABIC_TO_ROMAN_MAP.values.select {|n| n.size==1}).each.all?  { |ch|
                                   ! character.include?(ch * 4) }
    end

    def is_roman? numeral
      !numeral.is_a?(Fixnum) && only_roman_digits?(numeral) &&
                                roman_digits_in_order?(numeral) &&
                                all_roman_characters_less_than_three?(numeral)
    end

    #made this a private class, so that I can remove testing for a valid entry from it, and shrink
    #the method down a bit. Now that it's private, I can increase the likelihood that the
    #incoming value will be an arabic number that won't generate any bugs
    def to_roman_private arabic_number
      ARABIC_TO_ROMAN_MAP.keys.sort.reverse.inject("") {|roman_return_string,key|
        multiplier,arabic_number = arabic_number.divmod(key)
        roman_return_string += ARABIC_TO_ROMAN_MAP[key] * multiplier
      }
    end
  end
end
