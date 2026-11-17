import 'package:material_ui/material_ui.dart';

class AppDimensions {
  AppDimensions._();

  // Spacing & Padding
  static const double p4 = 4.0;
  static const double p8 = 8.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
  static const double p32 = 32.0;
  static const double p40 = 40.0;

  // Widget Heights
  static const double buttonHeight = 48.0;
  static const double inputHeight = 48.0;
  static const double bottomBarHeight = 64.0;
  static const double appBarHeight = 56.0;

  // Border Radii
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 6.0; // Standard for buttons and inputs
  static const double radiusCard = 12.0; // Standard for cards
  static const double radiusLarge = 16.0;
  static const double radiusPill = 20.0; // For status badges

  static const BorderRadius borderRadiusMedium =
      BorderRadius.all(Radius.circular(radiusMedium));
  static const BorderRadius borderRadiusCard =
      BorderRadius.all(Radius.circular(radiusCard));
  static const BorderRadius borderRadiusPill =
      BorderRadius.all(Radius.circular(radiusPill));

  // Elevation & Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color.fromRGBO(17, 2, 38, 0.05),
      offset: Offset(0, 2),
      blurRadius: 10,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> modalShadow = [
    BoxShadow(
      color: Color.fromRGBO(17, 2, 38, 0.12),
      offset: Offset(0, -4),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];
}
