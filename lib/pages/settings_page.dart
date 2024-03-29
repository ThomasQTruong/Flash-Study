import 'package:flash_study/main.dart';
import 'package:flash_study/pages/login_register_page.dart';
import 'package:flash_study/data/user_data.dart';
import 'package:flash_study/utils/simple_firebase.dart';
import 'package:flash_study/utils/simple_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';


/// The settings page.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.title});

  // Fields in a Widget subclass are always marked "final".
  final String title;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}


class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 2.0,
        shadowColor: Theme.of(context).colorScheme.inversePrimary,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ProgressHUD(
        child: Builder(
          builder: (context) => SettingsList(
            sections: [
              // Account section.
              SettingsSection(
                title: const Text("Account"),
                tiles: <SettingsTile>[
                  // Display logout/login based on if user is logged in.
                  (SimpleFirebase.isLoggedIn())
                      ? logoutButton() : loginOrRegisterButton(),
                ],
              ),
              // Themes section.
              SettingsSection(
                title: const Text("Themes"),
                tiles: <SettingsTile>[
                  SettingsTile.switchTile(
                    onToggle: (value) async{
                      // Toggle dark mode and update theme.
                      UserData.isDarkMode = !UserData.isDarkMode;

                      updateThemeAndState();

                      // Save to Firebase and SharedPreferences.
                      await SimpleFirebase.savePreferences();
                      await SimplePreferences.setDarkMode(UserData.isDarkMode);
                      setState(() {});
                    },
                    initialValue: UserData.isDarkMode,
                    leading: const Icon(Icons.dark_mode),
                    title: const Text("Dark Mode"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// Login/Register button widget.
  SettingsTile loginOrRegisterButton() {
    return SettingsTile.navigation(
      leading: const Icon(Icons.login),
      title: const Text("Login/Register"),
      onPressed: (context) async {
        // Go to login/register page.
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginRegisterPage(
              title: "Login/Register",
            ),
          ),
        ).then((_) {
          // Update settings page after returning.
          updateThemeAndState();
        });
      },
    );
  }


  /// Logout button widget.
  SettingsTile logoutButton() {
    return SettingsTile.navigation(
      leading: const Icon(Icons.logout),
      title: const Text("Logout"),
      onPressed: (context) async {
        // Show loading circle.
        final progress = ProgressHUD.of(context);
        progress?.show();

        await FirebaseAuth.instance.signOut();
        setState(() {});

        // Loaded, get dismiss loading circle.
        progress?.dismiss();
      },
    );
  }


  /// Updates the app's theme and state.
  void updateThemeAndState() {
    setState(() {
      UserData.updateTheme();
    });
    FlashStudy.of(context).setState(() {});
  }
}
