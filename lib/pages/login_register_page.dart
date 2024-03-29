import 'package:flash_study/utils/palette.dart';
import 'package:flash_study/utils/simple_firebase.dart';
import 'package:flash_study/utils/simple_sqflite.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';


/// The login/register page.
class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key, required this.title});

  // Fields in a Widget subclass are always marked "final".
  final String title;

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}


class _LoginRegisterPageState extends State<LoginRegisterPage> {
  String errorMessage = "";
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          builder: (context) => Center(
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 25.0,
                        right: 25.0,
                        bottom: 10.0
                    ),
                    child: TextField(
                      controller: emailController,
                      obscureText: false,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Email",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Password",
                      ),
                    ),
                  ),
                  displayError(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final progress = ProgressHUD.of(context);

                          final loginConfirmed = await getLoginConfirmation();
                          // User clicked cancel.
                          if (!loginConfirmed!) {
                            return;
                          }

                          progress?.show();
                          await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: emailController.text,
                            password: passwordController.text,
                          ).then((value) async {
                            await SimpleFirebase.loadPreferences();
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          }).catchError((error) {
                            setState(() => errorMessage = (error as
                            FirebaseAuthException).message.toString());
                          });

                          // Load/merge data from Firestore with local.
                          await SimpleFirebase.loginLoadSets();

                          // Re-sync with databases.
                          await SimpleFirebase.saveSets();
                          await SimpleSqflite.clearDatabase();
                          await SimpleSqflite.addAll();
                          progress?.dismiss();
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () async {
                          final progress = ProgressHUD.of(context);
                          progress?.show();

                          // Create account and then login.
                          await FirebaseAuth.instance.createUserWithEmailAndPassword(
                            email: emailController.text,
                            password: passwordController.text,
                          ).then((value) async {
                            await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text,
                            );

                            // Save current sets to freshly created account.
                            await SimpleFirebase.saveSets();

                            // Return to previous page.
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          }).catchError((error) {
                            setState(() => errorMessage = (error as
                            FirebaseAuthException).message.toString());
                          });

                          progress?.dismiss();
                        },
                        child: const Text(
                          "Signup",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  /// Displays the error for why the user cannot login/register.
  Padding displayError() {
    return Padding(
      padding: const EdgeInsets.only(
          top: 5.0,
          bottom: 5.0,
          left: 25.0,
          right: 25.0
      ),
      child: Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              child: Opacity(
                opacity: (errorMessage == "") ? 0.0 : 1.0,
                child: const Icon(
                  Icons.error,
                  color: Palette.errorColor,
                  size: 20,
                ),
              ),
            ),
            const TextSpan(text: "  "),
            TextSpan(
              text: errorMessage,
              style: const TextStyle(
                color: Palette.errorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// Gets user's confirmation to log in.
  Future<bool?> getLoginConfirmation() => showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
        title: const Text(
          "WARNING: If there are sets with the same name, the one on your account will be overwritten.",
          style: TextStyle(
            // fontWeight: FontWeight.bold,
          ),
        ),
        surfaceTintColor: Theme.of(context).canvasColor,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              "Cancel",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              "Proceed",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ]
    ),
  );
}