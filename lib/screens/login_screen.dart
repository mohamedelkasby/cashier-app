import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xff56B9F1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'cashier app',
              style: TextStyle(
                color: Colors.white,
                fontSize: 65,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 80),
            textFiled(context,
                usernameController: usernameController, label: "Username"),
            const SizedBox(height: 20),
            textFiled(context,
                usernameController: passwordController, label: "Password"),
          ],
        ),
      ),
    );
  }

  Widget textFiled(
    context, {
    required TextEditingController usernameController,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.25, bottom: 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(label.toUpperCase()),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width *
                0.5, // Half of the screen width
            child: TextField(
              controller: usernameController,
              decoration: InputDecoration(
                hintText: label,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
