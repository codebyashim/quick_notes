import 'package:flutter/material.dart';

class AppTheme {
  // Discord color palette
  static const Color background = Color(0xFF313338);
  static const Color surface = Color(0xFF2B2D31);
  static const Color surfaceDark = Color(0xFF1E1F22);
  static const Color inputFill = Color(0xFF383A40);
  static const Color primary = Color(0xFF5865F2);
  static const Color primaryVariant = Color(0xFF4752C4);
  static const Color error = Color(0xFFED4245);
  static const Color success = Color(0xFF57F287);
  static const Color textPrimary = Color(0xFFF2F3F5);
  static const Color textSecondary = Color(0xFFB5BAC1);
  static const Color textMuted = Color(0xFF80848E);
  static const Color divider = Color(0xFF3F4147);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primaryVariant,
        secondary: success,
        onSecondary: Colors.black,
        surface: surface,
        onSurface: textPrimary,
        error: error,
        onError: Colors.white,
        outline: divider,
        surfaceContainerHighest: inputFill,
        onSurfaceVariant: textSecondary,
      ),
      scaffoldBackgroundColor: background,
      cardColor: surface,
      dividerColor: divider,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textSecondary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textMuted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textSecondary,
          side: const BorderSide(color: divider),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: textSecondary),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: surfaceDark,
        selectedIconTheme: IconThemeData(color: primary),
        unselectedIconTheme: IconThemeData(color: textMuted),
        selectedLabelTextStyle:
            TextStyle(color: primary, fontWeight: FontWeight.w600),
        unselectedLabelTextStyle: TextStyle(color: textMuted),
        indicatorColor: Color(0xFF404EAA),
      ),
      textTheme: const TextTheme(
        displayLarge:
            TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        displayMedium:
            TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        displaySmall:
            TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        headlineLarge:
            TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        headlineMedium:
            TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        headlineSmall:
            TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleLarge:
            TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleMedium:
            TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        titleSmall:
            TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
        bodySmall: TextStyle(color: textMuted),
        labelLarge:
            TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(color: textSecondary),
        labelSmall: TextStyle(color: textMuted),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: inputFill,
        selectedColor: Color(0x4D5865F2),
        labelStyle: const TextStyle(color: textSecondary),
        side: const BorderSide(color: divider),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: const TextStyle(
            color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        contentTextStyle: const TextStyle(color: textSecondary),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: textSecondary,
        textColor: textPrimary,
      ),
      dividerTheme:
          const DividerThemeData(color: divider, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: inputFill,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: surface,
        textStyle: TextStyle(color: textPrimary),
      ),
    );
  }
}
