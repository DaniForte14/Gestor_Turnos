import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colores principales
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFF26A69A);
  static const Color accentColor = Color(0xFFFF4081);
  
  // Colores para estados y roles
  static const Color medicoColor = Color(0xFF1565C0);
  static const Color enfermeroColor = Color(0xFF00897B);
  static const Color tcaeColor = Color(0xFF7B1FA2);
  
  // Colores para estados de solicitudes
  static const Color pendingColor = Color(0xFFFFA000);
  static const Color approvedColor = Color(0xFF43A047);
  static const Color rejectedColor = Color(0xFFE53935);
  static const Color cancelledColor = Color(0xFF757575);
  
  // Colores de fondo
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);
  
  // Tema claro
  static ThemeData lightTheme = FlexThemeData.light(
    scheme: FlexScheme.blue,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 9,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 10,
      blendOnColors: false,
      textButtonSchemeColor: SchemeColor.secondary,
      elevatedButtonSchemeColor: SchemeColor.primary,
      toggleButtonsSchemeColor: SchemeColor.secondary,
      switchSchemeColor: SchemeColor.primary,
      checkboxSchemeColor: SchemeColor.primary,
      radioSchemeColor: SchemeColor.primary,
      inputDecoratorSchemeColor: SchemeColor.primary,
      inputDecoratorIsFilled: false,
      chipSchemeColor: SchemeColor.primary,
      navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
      navigationBarSelectedIconSchemeColor: SchemeColor.primary,
      navigationBarIndicatorSchemeColor: SchemeColor.primary,
      navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
      navigationRailSelectedIconSchemeColor: SchemeColor.primary,
      navigationRailIndicatorSchemeColor: SchemeColor.primary,
    ),
    keyColors: const FlexKeyColors(
      useSecondary: true,
      useTertiary: true,
    ),
    tones: FlexTones.vividBackground(Brightness.light),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    fontFamily: GoogleFonts.nunito().fontFamily,
  );
  
  // Tema oscuro
  static ThemeData darkTheme = FlexThemeData.dark(
    scheme: FlexScheme.blue,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 15,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 20,
      textButtonSchemeColor: SchemeColor.secondary,
      elevatedButtonSchemeColor: SchemeColor.primary,
      toggleButtonsSchemeColor: SchemeColor.secondary,
      switchSchemeColor: SchemeColor.primary,
      checkboxSchemeColor: SchemeColor.primary,
      radioSchemeColor: SchemeColor.primary,
      inputDecoratorSchemeColor: SchemeColor.primary,
      inputDecoratorIsFilled: false,
      chipSchemeColor: SchemeColor.primary,
      navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
      navigationBarSelectedIconSchemeColor: SchemeColor.primary,
      navigationBarIndicatorSchemeColor: SchemeColor.primary,
      navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
      navigationRailSelectedIconSchemeColor: SchemeColor.primary,
      navigationRailIndicatorSchemeColor: SchemeColor.primary,
    ),
    keyColors: const FlexKeyColors(
      useSecondary: true,
      useTertiary: true,
    ),
    tones: FlexTones.vividBackground(Brightness.dark),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    fontFamily: GoogleFonts.nunito().fontFamily,
  );
}
