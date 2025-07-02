import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color _primaryColor = Color(0xFFCBD4C2);
  static const Color _primaryVariantColor = Color(0xFF202531);
  static const Color _onPrimaryColor = Color(0xFFF28F3B);

  static const Color _appbarColor = Color(0xFF202531);
  static const Color _textColor = Color(0xFFCBD4C2);
  static const Color _iconColor = Color(0xFFF28F3B);
  static const Color _accentColor = Color(0xFF2D728F); //Color(0xFFB2E92E);

  // https://fonts.google.com/specimen/Montserrat
  static const TextStyle _headingText = TextStyle(
    color: _textColor,
    fontFamily: "Montserrat",
    fontSize: 18,
    fontVariations: <FontVariation>[
      FontVariation('wght', 600),
    ],
  );

  static const TextStyle _bodyTextLarge = TextStyle(
    color: _textColor,
    fontFamily: "Montserrat",
    fontSize: 16,
    fontVariations: <FontVariation>[
      FontVariation('wght', 450),
    ],
  );

  static final TextStyle _bodyTextMedium = _bodyTextLarge.copyWith(
    fontSize: 13,
  );

  static final TextStyle _bodyTextSmall = _bodyTextLarge.copyWith(
    fontSize: 10,
  );

  static final TextStyle _displayMediumText = _bodyTextMedium.copyWith(
    color: _textColor,
    fontSize: 16,
    fontVariations: <FontVariation>[
      const FontVariation('wght', 600),
    ],
  );

  static final TextStyle _appBarText = _headingText.copyWith(
    fontSize: 20,
    fontVariations: <FontVariation>[
      const FontVariation('wght', 500),
    ],
  );

  static final TextTheme _textTheme = TextTheme(
      displayLarge: _headingText,
      displayMedium: _displayMediumText,
      bodyLarge: _bodyTextLarge,
      bodyMedium: _bodyTextMedium,
      bodySmall: _bodyTextSmall);

  static final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _primaryVariantColor,
      appBarTheme: AppBarTheme(
        //color: _appbarColor,
        titleTextStyle: _appBarText,
        iconTheme: const IconThemeData(
          color: _iconColor,
        ),
        backgroundColor: _appbarColor,
        toolbarHeight: 60,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: _primaryVariantColor,
      ),
      bottomAppBarTheme: const BottomAppBarTheme(
        color: _appbarColor,
      ),
      colorScheme: const ColorScheme.light(
        primary: _primaryColor,
        onPrimary: _onPrimaryColor,
        secondary: _accentColor,
        primaryContainer: _primaryVariantColor,
      ),
      textTheme: _textTheme,
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white12,
      ),
      elevatedButtonTheme: const ElevatedButtonThemeData(
          style: ButtonStyle(
        elevation: WidgetStatePropertyAll(30),
        backgroundColor: WidgetStatePropertyAll(_iconColor),
        foregroundColor: WidgetStatePropertyAll(_primaryVariantColor),
      )),
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(
            _bodyTextLarge.copyWith(fontWeight: FontWeight.bold)),
      )),
      buttonTheme: const ButtonThemeData(
        buttonColor: _accentColor,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _onPrimaryColor,
      ),
      iconTheme: const IconThemeData(
        color: _iconColor,
      ),
      dialogTheme: DialogThemeData(
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        backgroundColor: Colors.white12,
        titleTextStyle: _bodyTextLarge.copyWith(fontWeight: FontWeight.bold),
        contentTextStyle: _bodyTextMedium.copyWith(fontWeight: FontWeight.bold),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(_primaryColor),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        elevation: 30.0,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(0),
          ),
        ),
        backgroundColor: _onPrimaryColor,
        contentTextStyle: _bodyTextLarge.copyWith(
          color: _primaryVariantColor,
        ),
      ),
      listTileTheme: const ListTileThemeData(textColor: _textColor),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: _accentColor),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _onPrimaryColor,
        foregroundColor: _primaryVariantColor,
      ));
}
