/// Sacred Radiance spacing tokens — strict 8 px base scale.
/// All paddings and margins in the app must be multiples of [base].
class SacredSpacing {
  SacredSpacing._();

  static const double base         = 8;   // fundamental unit
  static const double xs           = 4;   // micro gaps (icons, chips)
  static const double sm           = 12;  // tight inner padding
  static const double md           = 24;  // standard section gap
  static const double lg           = 48;  // section separator
  static const double xl           = 64;  // major content blocks
  static const double gutter       = 16;  // horizontal screen gutter
  static const double marginMobile = 20;  // outer screen margin (mobile)

  // Legacy alias — kept so any old references don't break
  static const double xxl = 32;
}
