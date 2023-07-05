import 'package:flash_study/pages/sets_page.dart';
import 'package:flash_study/data/user_data.dart';
import 'package:flash_study/utils/palette.dart';
import 'package:flash_study/utils/simple_firebase.dart';
import 'package:flash_study/utils/simple_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'data/firebase_options.dart';


/// Program starts here.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Wait for Shared Preferences to load.
  await SimplePreferences.init();

  // Is a website.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: "Flash Study",
      // Light/dark theme.
      theme: ThemeData(
        fontFamily: GoogleFonts.inconsolata().fontFamily,  // GoogleFonts.arvo().fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Palette.mainColor,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        fontFamily: GoogleFonts.inconsolata().fontFamily,  // GoogleFonts.arvo().fontFamily,
        colorScheme: const ColorScheme.dark(),
        useMaterial3: true,
      ),
      themeMode: UserData.currentTheme,
      home: const SetsPage(title: "Sets"),
    );
  }


  @override
  void initState() {
    super.initState();

    // Data loading in pages/sets_page.dart also.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load data from Firestore and sync with local.
      if (SimpleFirebase.isLoggedIn()) {
        await SimpleFirebase.loadPreferences();
        UserData.updateTheme();

        await SimplePreferences.saveAll();
      }

      // Update app.
      setState(() {});
    });
  }
}
