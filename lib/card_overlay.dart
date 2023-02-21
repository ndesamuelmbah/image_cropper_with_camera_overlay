///ISO Card formats
///https://www.iso.org/standard/70483.html
enum CardOverlayFormat {
  ///Most banking cards and ID cards
  cardID1,

  ///French and other ID cards. Visas.
  cardID2,

  ///United States government ID cards
  cardID3,

  ///SIM cards
  simID000
}

enum OverlayOrientation { landscape, portrait }

class CardOverlay {
  double ratio;
  double cornerRadius;
  double widthFraction;
  OverlayOrientation? orientation;
  CardOverlay(
      {this.ratio = 1.5,
      this.cornerRadius = 5,
      this.widthFraction = 1.0,
      this.orientation = OverlayOrientation.landscape}) {
    if (widthFraction < 0.1 || widthFraction > 1.0) {
      throw Exception(
          'widthFraction == $widthFraction must be between 0.1 and 1.0');
    }
  }

  static CardOverlay fromFormat(CardOverlayFormat format) {
    switch (format) {
      case (CardOverlayFormat.cardID1):
        return CardOverlay(ratio: 1.59, cornerRadius: 5, widthFraction: 1);
      case (CardOverlayFormat.cardID2):
        return CardOverlay(ratio: 1.42, cornerRadius: 5, widthFraction: 1);
      case (CardOverlayFormat.cardID3):
        return CardOverlay(ratio: 1.42, cornerRadius: 5, widthFraction: 1);
      case (CardOverlayFormat.simID000):
        return CardOverlay(ratio: 1.66, cornerRadius: 5, widthFraction: 1);
    }
  }

  factory CardOverlay.fromValues(
      {double ratio = 1.59,
      double cornerRadius = 5,
      double widthFraction = 1}) {
    return CardOverlay(
        ratio: ratio, cornerRadius: cornerRadius, widthFraction: widthFraction);
  }
}
