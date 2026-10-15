import 'package:flutter/widgets.dart';

class AppStrings {
  const AppStrings(this.locale);

  final Locale locale;

  bool get isMyanmar => locale.languageCode == 'my';

  static const supportedLocales = <Locale>[Locale('en'), Locale('my')];

  static AppStrings of(BuildContext context) {
    return AppStrings(Localizations.localeOf(context));
  }

  String get appTitle => isMyanmar ? 'ကျွန်ုပ်၏အက်ပ်' : 'My App';

  String get welcome => isMyanmar ? 'ကြိုဆိုပါတယ်' : 'Welcome';

  String get description =>
      isMyanmar ? 'သင့်အကောင့်မှ ကြိုဆိုပါတယ်။' : 'Welcome to your account.';

  String get login => isMyanmar ? 'အကောင့်ဝင်ရန်' : 'Login';

  String get loginFailed => isMyanmar ? 'အကောင့်ဝင်ရန် မအောင်မြင်ပါ' : 'Login Failed';

  String get invalidCredentials => isMyanmar ? 'အကောင့်ဝင်ရန် မအောင်မြင်ပါ' : 'Invalid Credentials';

  String get register => isMyanmar ? 'အကောင့်ဖွင့်ရန်' : 'Register';

  String get email => isMyanmar ? 'အီးမေးလ်' : 'Email';

  String get name => isMyanmar ? 'နာမည်' : 'Name';

  String get back => isMyanmar ? 'နောက်သို့' : 'Back';

  String get password => isMyanmar ? 'စကားဝှက်' : 'Password';

  String get settings => isMyanmar ? 'ဆက်တင်များ' : 'Settings';

  String get language => isMyanmar ? 'ဘာသာစကား' : 'Language';

  String get english => 'English';

  String get myanmar => 'မြန်မာ';

  String get save => isMyanmar ? 'သိမ်းဆည်းရန်' : 'Save';

  String get ok => isMyanmar ? 'အိုကေ' : 'OK';

  String get rememberMe => isMyanmar ? 'မှတ်ထားပါ' : 'Remember Me';

  String get forgetPassword => isMyanmar ? 'စကားဝှက်မေ့နေပါသလား?' : 'Forget Password?';

  String get sendReset => isMyanmar ? 'ပြန်လည်သတ်မှတ်ရန်' : 'Send Reset Link';

  String get loading => isMyanmar ? 'ခဏစောင့်ပါ' : 'Loading...';

  String get cancel => isMyanmar ? 'မလုပ်တော့ပါ' : 'Cancel';

  String get success => isMyanmar ? 'အောင်မြင်ပါသည်' : 'Success';

  String get requiredField =>
      isMyanmar ? 'ဤအကွက်ကို ဖြည့်ရန်လိုအပ်သည်။' : 'This field is required.';
}
