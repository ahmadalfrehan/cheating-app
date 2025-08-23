import 'package:cheating_detection/getx/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '', password = '';

  void _submit() {
    controller.performLogin();

    // Navigator.pushNamed(context, '/classes');
  }

  final controller = Get.put(AppController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'Login',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Email'),
                    // onChanged: (val) => email = val,
                    controller: controller.email,
                    validator:
                        (val) => val!.isEmpty ? 'Enter your email' : null,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    // onChanged: (val) => password = val,
                    controller: controller.password,
                    validator:
                        (val) => val!.length < 6 ? 'Enter min 6 chars' : null,
                  ),
                  SizedBox(height: 30),
                  Obx(
                    () =>
                        controller.isLogging.value
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 50),
                              ),
                              child: Text('Login'),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
