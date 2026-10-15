import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui_27/authservice.dart';
import 'package:forui_27/home.dart';
import 'package:forui_27/l10n/app_strings.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController nameControl = TextEditingController();
  TextEditingController emailControl = TextEditingController();
  TextEditingController passControl = TextEditingController();

  final Authservice _authService = Authservice();

  void register() async {
    final name = nameControl.text;
    final email = emailControl.text;
    final password = passControl.text;
    // Implement your registration logic here
    try {
      final response = await _authService.signUp(email, password, name);
      // print('Registration response: $response');
      if (response.user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (context) => const Home()),
        );
      } else {
        FToast(
          title: Text('Login Failed'),
          description: Text('Invalid credentials'),
        );
      }
    } catch (e) {
      // print('Registration error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return FScaffold(
      child: Center(
        child: SizedBox(
          width: 300,
          height: 400,
          child: FCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                spacing: 16,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Register'),
                  FTextField(
                    label: Text(strings.name),
                    clearable: (p0) => true,
                    control: FTextFieldControl.managed(controller: nameControl),
                  ),
                  FTextField(
                    label: Text(strings.email),
                    clearable: (p0) => true,
                    control: FTextFieldControl.managed(
                      controller: emailControl,
                    ),
                  ),
                  FTextField(
                    label: Text(strings.password),
                    clearable: (p0) => true,
                    control: FTextFieldControl.managed(controller: passControl),
                  ),
                  FButton(onPress: register, child: Text(strings.register)),
                  FButton(
                    onPress: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(strings.back),
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
