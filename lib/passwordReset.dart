import 'package:forui/forui.dart';
import 'package:forui_27/authservice.dart';
import 'package:forui_27/l10n/app_strings.dart';
import 'package:material_ui/material_ui.dart';

class Passwordreset extends StatefulWidget {
  const Passwordreset({super.key});

  @override
  State<Passwordreset> createState() => _PasswordresetState();
}

class _PasswordresetState extends State<Passwordreset> {
  bool rememberMe = false;
  bool isLoading = false;

  final TextEditingController emailControl = TextEditingController();
  final TextEditingController passwordControl = TextEditingController();
  final TextEditingController otpControl = TextEditingController();

  final Authservice _authService = Authservice();

  @override
  void dispose() {
    emailControl.dispose();
    otpControl.dispose();
    super.dispose();
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

    return FScaffold(
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
                    strings.forgetPassword,
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
                  Row(
                    spacing: 8,
                    crossAxisAlignment: .end,
                    children: [
                      Expanded(
                        child: FTextField(
                          label: Text("OTP"),
                          control: FTextFieldControl.managed(
                            controller: otpControl,
                          ),
                        ),
                      ),
                      FButton(
                        onPress: () {
                          _authService.sendEmailOtp(emailControl.text);
                        },
                        child: Text("Send OTP"),
                      ),
                    ],
                  ),
                  FTextField(
                    label: Text("New Password"),
                    control: FTextFieldControl.managed(
                      controller: passwordControl,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FButton(
                      onPress: isLoading
                          ? null
                          : () async {
                              var resp = await _authService.verifyEmailOtp(
                                email: emailControl.text,
                                token: otpControl.text,
                              );
                              if (resp.user != null) {
                                await _authService.updatePassword(
                                  passwordControl.text,
                                );
                                showMessage(
                                  "Success",
                                  "Password has been reset successfully.",
                                );
                              } else {
                                showMessage(
                                  "Error",
                                  "Failed to reset password. Please check your OTP and try again.",
                                );
                              }
                            },
                      child: Text(
                        isLoading ? strings.loading : strings.sendReset,
                      ),
                    ),
                  ),
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
