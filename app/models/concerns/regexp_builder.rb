module RegexpBuilder
  include AddressTerms
  include NewYorkAddressTerms
  
  def regExpType(x)
    "(#{x.join("|")})"
  end

  def cardinal_street_names
    "[0-9]+#{regExpType(CardinalSuffix)}?"
  end

  def all_street_names
    "(#{regExpType(NewYorkStreetNames)}|#{cardinal_street_names})"
  end

  def full_street_names
    "(#{regExpType(StreetPrefixSuffix)}\\s*)?#{all_street_names}\\s*(#{regExpType(StreetPrefixSuffix)}\\W)?\\W*#{regExpType(StreetTypes)}?(\\W#{regExpType(StreetPrefixSuffix)}\\W)?"
  end

  def full_proper_street_names
    "(#{regExpType(StreetPrefixSuffix)}\\s*)?#{all_street_names}\\s*(#{regExpType(StreetPrefixSuffix)}\\W)?\\W*#{regExpType(StreetTypes)}"
  end

#including "-" as an and fixes some problems and causes others
  def intersection
    "#{full_street_names}\\W*(and|n|\\/|\\|\\+|&|&amp;|@)\\W*#{full_street_names}"
  end

  def intersection_first_street
    "#{full_street_names}(?=\\W*and\\W*)"
  end

  def intersection_second_street
    "(?<=\\Wand\\W)#{full_street_names}"
  end

  def include_between
    "#{full_street_names}(\\W*(between|\\s)+\\W*|\\W+)#{intersection}"
  end

  def between_address_first_part
    "#{full_street_names}(?=\\W*(between|\\s)|#{intersection})"
  end

  def street_address
    "\\b[0-9]+\\W+#{full_proper_street_names}"
  end

  def final_regexp_string
    "(#{include_between}|#{intersection}|#{street_address})"
  end

  def brooklyn_regexp
    "(^|\\W+)#{regExpType(BrooklynNames)}($|\\W+)"
  end

  def queens_regexp
    "(^|\\W+)#{regExpType(QueensNames)}($|\\W+)"
  end

  def get_regexp(regexp_text)
    regexp_text = "(\\b#{regexp_text})\\b"
    Regexp.new(regexp_text, Regexp::IGNORECASE)
  end
end