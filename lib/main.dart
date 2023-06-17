import 'package:flash_study/pages/sets_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run app.
  runApp(const FlashStudy());
}

class FlashStudy extends StatefulWidget {
  const FlashStudy({super.key});

  @override
  State<FlashStudy> createState() => FlashStudyState();

  static FlashStudyState of(BuildContext context) =>
      context.findAncestorStateOfType<FlashStudyState>()!;
}

class FlashStudyState extends State<FlashStudy>{
  ThemeMode currentThemeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: "Flash Study",
      theme: ThemeData(
        fontFamily: GoogleFonts.arvo().fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 133, 218, 255),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        fontFamily: GoogleFonts.arvo().fontFamily,
        colorScheme: const ColorScheme.dark(),
        useMaterial3: true,
      ),
      themeMode: currentThemeMode,
      home: const SetsPage(title: "Sets"),
    );
  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      currentThemeMode = themeMode;
    });
  }
}
