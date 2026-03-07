import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/api_provider.dart';
import 'providers/report_provider.dart';
import 'providers/terminal_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AutoMiumApp());
}

class AutoMiumApp extends StatelessWidget {
  const AutoMiumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => TerminalProvider()),
      ],
      child: MaterialApp(
        title: 'AutoMium',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          // Primary Colors - Futuristic Blue
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF0066FF),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF0066FF),
            secondary: Color(0xFF00D4FF),
            tertiary: Color(0xFF00FFFF),
            surface: Color(0xFF0A0E27),
            background: Color(0xFF050818),
            error: Color(0xFFFF3366),
            onPrimary: Color(0xFFFFFFFF),
            onSecondary: Color(0xFF000000),
            onSurface: Color(0xFFFFFFFF),
            onError: Color(0xFFFFFFFF),
          ),
          scaffoldBackgroundColor: const Color(0xFF050818),
          
          // AppBar Theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0A0E27),
            foregroundColor: Color(0xFF00D4FF),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00D4FF),
              letterSpacing: 1.2,
            ),
          ),
          
          // Card Theme - Glassmorphism effect
          cardTheme: CardThemeData(
            color: const Color(0xFF0F1535).withOpacity(0.8),
            elevation: 8,
            shadowColor: const Color(0xFF0066FF).withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: const Color(0xFF00D4FF).withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          
          // Elevated Button Theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066FF),
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: const Color(0xFF0066FF).withOpacity(0.5),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          
          // Input Decoration Theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF0F1535).withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0066FF), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFF0066FF).withOpacity(0.3), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00D4FF), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF3366), width: 1),
            ),
            prefixIconColor: const Color(0xFF00D4FF),
            labelStyle: const TextStyle(color: Color(0xFF00D4FF)),
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          ),
          
          // Navigation Rail Theme
          navigationRailTheme: const NavigationRailThemeData(
            backgroundColor: Color(0xFF0A0E27),
            indicatorColor: Color(0xFF0066FF),
            selectedIconTheme: IconThemeData(color: Color(0xFF00D4FF), size: 28),
            unselectedIconTheme: IconThemeData(color: Color(0xFF6B7B9F), size: 24),
            selectedLabelTextStyle: TextStyle(
              color: Color(0xFF00D4FF),
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelTextStyle: TextStyle(
              color: Color(0xFF6B7B9F),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
