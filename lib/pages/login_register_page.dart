import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      body: Center(
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
                  onPressed: () {
                    FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: emailController.text,
                      password: passwordController.text,
                    ).then((value) {
                      setState(() => Navigator.pop(context));
                    }).catchError((error) {
                      setState(() => errorMessage = (error as
                                     FirebaseAuthException).message.toString());
                    });
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
                  onPressed: () {
                    // Create account and then login.
                    FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: emailController.text,
                      password: passwordController.text,
                    ).then((value) {
                      FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: emailController.text,
                        password: passwordController.text,
                      );

                      // Return to previous page.
                      setState(() => Navigator.pop(context));
                    }).catchError((error) {
                      setState(() => errorMessage = (error as
                                     FirebaseAuthException).message.toString());
                    });
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
    );
  }


  Padding displayError() {
    return Padding(
      padding: const EdgeInsets.only(
          top: 5.0,
          bottom: 15.0,
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
                  color: Color.fromRGBO(217, 48, 37, 1.0),
                  size: 20,
                ),
              ),
            ),
            const TextSpan(text: "  "),
            TextSpan(
              text: errorMessage,
              style: const TextStyle(
                color: Color.fromRGBO(217, 48, 37, 1.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}