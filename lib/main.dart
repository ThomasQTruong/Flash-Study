import 'package:flash_study/pages/sets_page.dart';
import 'package:flash_study/data/user_data.dart';
import 'package:flash_study/utils/palette.dart';
import 'package:flash_study/utils/simple_firebase.dart';
import 'package:flash_study/utils/simple_preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

  await SimplePreferences.init();

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
      theme: ThemeData(
        fontFamily: GoogleFonts.arvo().fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Palette.mainColor,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        fontFamily: GoogleFonts.arvo().fontFamily,
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Wait for data to load if any.
      await SimpleFirebase.loadData();
      UserData.updateTheme();

      // Update app.
      setState(() {});
    });
  }
}
