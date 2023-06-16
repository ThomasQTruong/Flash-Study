import 'package:flash_study/pages/sets_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ColorScheme lightMode = ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 133, 218, 255));
ColorScheme darkMode = const ColorScheme.dark(primary: Colors.white);

void main() {
  runApp(const FlashStudy());
}

class FlashStudy extends StatelessWidget {
  const FlashStudy({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flash Study",
      theme: ThemeData(
        fontFamily: GoogleFonts.arvo().fontFamily,
        colorScheme: lightMode,
        useMaterial3: true,
      ),
      home: const SetsPage(title: "Sets"),
    );
  }
}
