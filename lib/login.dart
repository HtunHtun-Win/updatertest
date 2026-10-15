import 'package:forui/forui.dart';
import 'package:forui_27/authservice.dart';
import 'package:forui_27/home.dart';
import 'package:forui_27/main.dart';
import 'package:forui_27/passwordReset.dart';
import 'package:forui_27/register.dart';
import 'package:forui_27/l10n/app_strings.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool rememberMe = false;
  bool isLoading = false;

  final TextEditingController emailControl = TextEditingController();
  final TextEditingController passControl = TextEditingController();

  final Authservice _authService = Authservice();

  @override
  void dispose() {
    emailControl.dispose();
    passControl.dispose();
    super.dispose();
  }

  // Future<void> login() async {
  //   final strings = AppStrings.of(context);
  //   final email = emailControl.text.trim();
  //   final password = passControl.text;

  //   if (email.isEmpty || password.isEmpty) {
  //     showMessage(strings.loginFailed, strings.requiredField);
  //     return;
  //   }
  //   final response = await _authService.signIn(email, password);
  //   if (response.user != null) {
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setBool('remember_me', rememberMe);

  //     if (!mounted) return;

  //     Navigator.of(
  //       context,
  //     ).pushReplacement(MaterialPageRoute<void>(builder: (_) => const Home()));
  //   } else {
  //     showMessage(strings.loginFailed, strings.invalidCredentials);
  //   }
  // }

  Future<void> login() async {
    if (isLoading) return;

    final strings = AppStrings.of(context);
    final email = emailControl.text.trim();
    final password = passControl.text;

    if (email.isEmpty || password.isEmpty) {
      showMessage(strings.loginFailed, strings.requiredField);
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await _authService.signIn(email, password);
      if (!mounted) return;
      if (response.user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('remember_me', rememberMe);

        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const Home()),
        );
      } else {
        showMessage(strings.loginFailed, strings.invalidCredentials);
      }
    } catch (e) {
      if (!mounted) return;
      // showMessage(strings.loginFailed, strings.invalidCredentials);
      // showMessage("",e.toString());
      // debugPrint(e.toString());
      showFToast(
        context: context,
        alignment: FToastAlignment.topCenter,
        title: Text(strings.loginFailed,style: TextStyle(color: Colors.red),),
        description: Text(strings.invalidCredentials),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void showMessage(String title, String description) {
    // Replace with your app's FToaster notification method if needed.
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppStrings.of(context).ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final appLocale = AppLocaleScope.of(context);

    return FScaffold(
      header: FHeader(
        title: Text(strings.login),
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.languages),
            onPress: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (sheetContext) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('English'),
                        trailing: appLocale.locale.languageCode == 'en'
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () {
                          Navigator.pop(sheetContext);
                          appLocale.changeLanguage('en');
                        },
                      ),
                      ListTile(
                        title: const Text('မြန်မာ'),
                        trailing: appLocale.locale.languageCode == 'my'
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () {
                          Navigator.pop(sheetContext);
                          appLocale.changeLanguage('my');
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 320,
          child: FCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  Text(
                    strings.login,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FTextField(
                    label: Text(strings.email),
                    control: FTextFieldControl.managed(
                      controller: emailControl,
                    ),
                  ),
                  FTextField(
                    label: Text(strings.password),
                    control: FTextFieldControl.managed(controller: passControl),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: FCheckbox(
                          label: Text(strings.rememberMe),
                          value: rememberMe,
                          onChange: (value) {
                            setState(() => rememberMe = value);
                          },
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const Passwordreset(),
                              ),
                            );
                          },
                          child: Text(strings.forgetPassword),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FButton(
                      onPress: isLoading ? null : login,
                      child: Text(isLoading ? strings.loading : strings.login),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FButton(
                      onPress: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const Register(),
                          ),
                        );
                      },
                      child: Text(strings.register),
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
