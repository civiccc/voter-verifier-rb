namespace rb ThriftDefs.GeoTypes

typedef double Latitude
typedef double Longitude
typedef string ZipCode

struct Coordinate {
  1: Latitude lat( description="Latitude" ),
  2: Longitude lng( description="Longitude" ),
}

enum StateCode {
  AL = 1, // Alabama
  AK = 2, // Alaska
  AZ = 3, // Arizona
  AR = 4, // Arkansas
  CA = 5, // California
  CO = 6, // Colorado
  CT = 7, // Connecticut
  DE = 8, // Delaware
  DC = 9, // District of Columbia
  FL = 10, // Florida
  GA = 11, // Georgia
  HI = 12, // Hawaii
  ID = 13, // Idaho
  IL = 14, // Illinois
  IN = 15, // Indiana
  IA = 16, // Iowa
  KS = 17, // Kansas
  KY = 18, // Kentucky
  LA = 19, // Louisiana
  ME = 20, // Maine
  MD = 21, // Maryland
  MA = 22, // Massachusetts
  MI = 23, // Michigan
  MN = 24, // Minnesota
  MS = 25, // Mississippi
  MO = 26, // Missouri
  MT = 27, // Montana
  NE = 28, // Nebraska
  NV = 29, // Nevada
  NH = 30, // New Hampshire
  NJ = 31, // New Jersey
  NM = 32, // New Mexico
  NY = 33, // New York
  NC = 34, // North Carolina
  ND = 35, // North Dakota
  OH = 36, // Ohio
  OK = 37, // Oklahoma
  OR = 38, // Oregon
  PA = 39, // Pennsylvania
  RI = 40, // Rhode Island
  SC = 41, // South Carolina
  SD = 42, // South Dakota
  TN = 43, // Tennessee
  TX = 44, // Texas
  UT = 45, // Utah
  VT = 46, // Vermont
  VA = 47, // Virginia
  WA = 48, // Washington
  WV = 49, // West Virginia
  WI = 50, // Wisconsin
  WY = 51, // Wyoming
  AA = 52, // Armed Forces Americas
  AE = 53, // Armed Forces Europe
  AP = 54, // Armed Forces Pacific
}

struct Address {
  1: string street ( description="The unparsed street address" ),
  2: string street_name ( description="The street name part of `street`" ),
  3: string street_number ( description="The street number part of `street`" ),
  4: string unit_designator( description="The type of `apt_number` parsed from `street` (e.g. \"Apt\" or \"Suite\")" ),
  5: string apt_number ( description="The unit or apartment number parsed from `street`" ),
  6: string city,
  7: StateCode state,
  8: ZipCode zip_code,
}

struct Addresses {
  1: list<Address> addresses
}
