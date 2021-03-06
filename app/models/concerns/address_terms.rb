module AddressTerms
  
  CardinalSuffix = ['st','nd','rd','th']
  #CardinalSuffix = ["[s|n|r|t][a-z]","[a-z][t|d|h]"]
  
  StreetTypes =
  [
    "st",
    "street",
    "ave",
    "av",
    "avenue",
    "blvd",
    "boulevard",
    "ln",
    "lane",
    "rd",
    "road",
    "pl",
    "place",
    "dr",
    "drive",
    "rw",
    "row",
    "sq",
    "square",
    "cir",
    "circ",
    "circle",
    "sl",
    "slip"
  ]

  StreetPrefixSuffix = ["north","south","east","west","n","s","e","w","n/.","s/.","e/.","w/."]
  
  BetweenTypes = ["b.{0,3}w.{0,2}n","bet","bw","b/w","b/t","bt","\\s"]
  
end