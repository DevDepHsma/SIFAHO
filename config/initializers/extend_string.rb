# RemoveAccents version 1.0.3 (c) 2008-2009 Solutions Informatiques Techniconseils inc.
#
# This module adds 2 methods to the string class.
# Up-to-date version and documentation available at:
#
# http://www.techniconseils.ca/en/scripts-remove-accents-ruby.php
#
# This script is available under the following license :
# Creative Commons Attribution-Share Alike 2.5.
#
# See full license and details at :
# http://creativecommons.org/licenses/by-sa/2.5/ca/
#
# Version history:
#   * 1.0.4 : August 23 2016
#           Fix Regexp constructor.
#   * 1.0.3 : July 23 2009
#               Corrected some incorrect character codes. Source is now wikipedia at:
#                 http://en.wikipedia.org/wiki/ISO/IEC_8859-1#Related_character_maps
#               Thanks to Raimon Fernandez for pointing out the incorrect codes.
#   * 1.0.2 : October 29 2008
#               Slightly optimized version of urlize - Jonathan Grenier (jgrenier@techniconseils.ca)
#   * 1.0.1 : October 29 2008
#               First public revision - Jonathan Grenier (jgrenier@techniconseils.ca)
#

class String
  # The extended characters map used by removeaccents. The accented characters
  # are coded here using their numerical equivalent to sidestep encoding issues.
  # These correspond to ISO-8859-1 encoding.
  UNACCENTS_MAPPING = {
    'E' => [200, 201, 202, 203],
    'e' => [232, 233, 234, 235],
    'A' => [192, 193, 194, 195, 196, 197],
    'a' => [224, 225, 226, 227, 228, 229, 230],
    'C' => [199],
    'c' => [231],
    'O' => [210, 211, 212, 213, 214, 216],
    'o' => [242, 243, 244, 245, 246, 248],
    'I' => [204, 205, 206, 207],
    'i' => [236, 237, 238, 239],
    'U' => [217, 218, 219, 220],
    'u' => [249, 250, 251, 252],
    'N' => [209],
    'n' => [241],
    'Y' => [221],
    'y' => [253, 255],
    'AE' => [306],
    'ae' => [346],
    'OE' => [188],
    'oe' => [189]
  }

  ACCENTS_MAPPING = {
    'É' => [200, 202, 203],
    'é' => [232, 234, 235],
    'Á' => [192, 194, 195, 196, 197],
    'á' => [224, 226, 227, 228, 229, 230],
    'Ó' => [210, 212, 213, 214, 216],
    'ó' => [242, 244, 245, 246, 248],
    'Í' => [204, 206, 207],
    'í' => [236, 238, 239],
    'Ú' => [217, 219, 220],
    'ú' => [249, 251, 252]
  }

  HTML_ACCENTS_MAPPING = {
    '&Eacute' => [200, 201, 202, 203],
    '&eacute' => [232, 233, 234, 235],
    '&Aacute' => [192, 193, 194, 195, 196, 197],
    '&aacute' => [224, 225, 226, 227, 228, 229, 230],
    '&Oacute' => [210, 211, 212, 213, 214, 216],
    '&oacute' => [242, 243, 244, 245, 246, 248],
    '&Iacute' => [204, 205, 206, 207],
    '&iacute' => [236, 237, 238, 239],
    '&Uacute' => [217, 218, 219, 220],
    '&uacute' => [249, 250, 251, 252],
    '&Ntilde;' => [209],
    '&ntilde;' => [241],
    '&deg;' => [186, 176]
  }

  TO_DEGREE_MAPPING = {
    '°' => [186, 176]
  }

  # Remove the accents from the string. Uses String::UNACCENTS_MAPPING as the source map.
  def removeaccents
    replace_chars_in_string_with(String::UNACCENTS_MAPPING)
  end

  # replace the accents from the string to HTML name. Uses String::HTML_ACCENTS_MAPPING as the source map.
  def replace_accents_as_html
    replace_chars_in_string_with(String::HTML_ACCENTS_MAPPING)
  end

  # replace the masculine ordinal indicator to degree sign. Uses String::TO_DEGREE_MAPPING as the source map.
  def to_degree
    replace_chars_in_string_with(String::TO_DEGREE_MAPPING)
  end

  def to_permite_accents
    replace_chars_in_string_with(String::ACCENTS_MAPPING)
  end

  def replace_chars_in_string_with(chars_mapping)
    str = String.new(self)
    chars_mapping.each do |letter, accents|
      packed = accents.pack('U*')
      rxp = Regexp.new("[#{packed}]", nil)
      str.gsub!(rxp, letter)
    end
    str
  end
end
