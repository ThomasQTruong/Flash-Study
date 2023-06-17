import 'package:flash_study/main.dart';
import 'package:flash_study/pages/login_register_page.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';

bool isDarkMode = false;

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
      appBar: AppBar(
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
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text("Account"),
            tiles: <SettingsTile>[
              (FirebaseAuth.instance.currentUser == null)
                          ? loginOrRegisterButton() : logoutButton(),
            ],
          ),
          SettingsSection(
            title: const Text("Themes"),
            tiles: <SettingsTile>[
              SettingsTile.switchTile(
                onToggle: (value) {
                  setState(() {
                    isDarkMode = !isDarkMode;
                    changeTheme();
                  });
                },
                initialValue: isDarkMode,
                leading: const Icon(Icons.dark_mode),
                title: const Text("Dark Mode"),
              ),
            ],
          ),
        ],
      ),
    );
  }


  void changeTheme() {
    setState(() {
      FlashStudy.of(context).changeTheme(isDarkMode ? ThemeMode.dark
                                                    : ThemeMode.light);
    });
  }


  SettingsTile loginOrRegisterButton() {
    return SettingsTile.navigation(
      leading: const Icon(Icons.login),
      title: const Text("Login/Register"),
      onPressed: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginRegisterPage(
              title: "Login/Register",
            ),
          ),
        );
      },
    );
  }


  SettingsTile logoutButton() {
    return SettingsTile.navigation(
      leading: const Icon(Icons.logout),
      title: const Text("Logout"),
      onPressed: (context) {
      },
    );
  }
}
