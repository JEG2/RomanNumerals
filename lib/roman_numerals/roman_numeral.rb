module RomanNumerals
  class RomanNumeral
    def initialize
      @arabic_roman_map = { 1 => "I",   4 => "IV",
                            5 => "V",   9 => "IX",
                            10 => "X",  40 => "XL",
                            50 => "L",  90 => "XC",
                            100 => "C", 400 => "CD",
                            500 => "D", 900 => "CM",
                            1000 => "M"
      }
      @roman_arabic_map = @arabic_roman_map.invert
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

    def roman_each roman_numeral
      working_number = roman_numeral.dup
      while working_number.size > 0 do
        yield roman_find_two_digit(working_number) || roman_find_one_digit(working_number)
      end
    end

    def roman_find_two_digit roman_numeral
          return @roman_arabic_map[roman_numeral.slice!(-2,2)] if
                                            roman_numeral.size >= 2 &&
                                           @roman_arabic_map[roman_numeral[-2,2]]
          return false
    end

    def roman_find_one_digit roman_numeral
        return  @roman_arabic_map[roman_numeral.slice!(-1)] if
                                @roman_arabic_map[roman_numeral[-1]]
        return false
    end

    def only_roman_digits? roman_number
      remainder= roman_number.dup
      @arabic_roman_map.each_value {|value| remainder.delete!(value) }
      !(remainder.size > 0 )
    end

    def roman_digits_in_order? roman_number
      roman_split(roman_number).each_cons(2).all? { |a| a[0] <= a[1] }
    end

    def all_roman_characters_less_than_three? character
      (@arabic_roman_map.values.select {|n| n.size==1}).each.all?  { |ch|
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
      @arabic_roman_map.keys.sort.reverse.inject("") {|roman_return_string,key|
        multiplier,arabic_number = arabic_number.divmod(key)
        roman_return_string += @arabic_roman_map[key] * multiplier
      }
    end
  end
end
