import 'package:flutter/foundation.dart';
import 'package:flutter_desktop_updater/flutter_desktop_updater.dart';
import 'package:forui/forui.dart';
// import 'package:material_ui/material_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:forui_27/splashScreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  UpdateConfig().configure(
    updateJsonUrl: 'https://github.com/HtunHtun-Win/updatertest/blob/main/update.json',
  );

  // Initialize Supabase before the app starts.
  await Supabase.initialize(
    url: 'https://tlsrgmsvzgkpfwczywdy.supabase.co',
    publishableKey: 'sb_publishable_P50SkccH2-2bzuT_L4smvQ_yt2qvBNp',
  );

  // Restore the previously selected language.
  final preferences = await SharedPreferences.getInstance();
  final savedLanguage = preferences.getString('app_language');

  final initialLocale = savedLanguage == 'my'
      ? const Locale('my')
      : const Locale('en');

  runApp(MyApp(initialLocale: initialLocale));
}

class AppLocaleScope extends InheritedWidget {
  const AppLocaleScope({
    super.key,
    required this.locale,
    required this.changeLanguage,
    required super.child,
  });

  final Locale locale;
  final Future<void> Function(String languageCode) changeLanguage;

  static AppLocaleScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();

    assert(scope != null, 'AppLocaleScope not found in widget tree.');

    return scope!;
  }

  @override
  bool updateShouldNotify(AppLocaleScope oldWidget) {
    return locale != oldWidget.locale;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.initialLocale});

  final Locale initialLocale;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  Future<void> _changeLanguage(String languageCode) async {
    if (languageCode != 'en' && languageCode != 'my') {
      return;
    }

    final newLocale = Locale(languageCode);

    if (_locale == newLocale) return;

    // Update the interface immediately.
    setState(() {
      _locale = newLocale;
    });

    // Save the choice for the next app launch.
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('app_language', languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = const <TargetPlatform>{
      TargetPlatform.android,
      TargetPlatform.iOS,
      TargetPlatform.fuchsia,
    }.contains(defaultTargetPlatform);

    final lightTheme = isMobile
        ? FTheme.neutral.light.touch
        : FTheme.neutral.light.desktop;

    final darkTheme = isMobile
        ? FTheme.neutral.dark.touch
        : FTheme.neutral.dark.desktop;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,

      supportedLocales: {
        ...FLocalizations.supportedLocales,
        const Locale('en'),
        const Locale('my'),
      }.toList(),

      localizationsDelegates: [
        ...FLocalizations.localizationsDelegates,
        ...GlobalMaterialLocalizations.delegates,
        // ...GlobalWidgetsLocalizations.delegates,
        ...GlobalCupertinoLocalizations.delegates,
      ],

      theme: ThemeData(brightness: Brightness.light),

      builder: (context, child) {
        final currentTheme = Theme.brightnessOf(context) == Brightness.light
            ? lightTheme
            : darkTheme;

        return FTheme(
          data: currentTheme,
          child: FToaster(
            child: FTooltipGroup(
              child: AppLocaleScope(
                locale: _locale,
                changeLanguage: _changeLanguage,
                child: child!,
              ),
            ),
          ),
        );
      },

      home: const SplashScreen(),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:forui/forui.dart';

// class AppLocaleScope extends InheritedWidget {
//   const AppLocaleScope({
//     super.key,
//     required this.locale,
//     required this.changeLanguage,
//     required super.child,
//   });

//   final Locale locale;
//   final Future<void> Function(String languageCode) changeLanguage;

//   static AppLocaleScope of(BuildContext context) {
//     final scope = context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();

//     assert(scope != null, 'AppLocaleScope not found in widget tree.');

//     return scope!;
//   }

//   @override
//   bool updateShouldNotify(AppLocaleScope oldWidget) {
//     return locale != oldWidget.locale;
//   }
// }

// // Requires a recent Forui (0.2x) and Flutter 3.44+ / Dart 3.10+ (dot shorthands).
// void main() => runApp(const TodoApp());

// /// App strings. To use another language, edit the 'hi' map or add a new
// /// entry (e.g. 'th', 'km', 'es') and add it to [AppLang].
// /// Forui itself supports 115 languages, so its built-in text follows the locale.
// enum AppLang { en, my }

// const Map<AppLang, Map<String, String>> _strings = {
//   AppLang.en: {
//     'title': 'My Todos',
//     'hint': 'What needs to be done?',
//     'add': 'Add',
//     'empty': 'No tasks yet. Add your first one!',
//     'pending': 'Pending',
//     'done': 'Done',
//     'clearDone': 'Clear completed',
//     'language': 'မြန်မာ',
//     'dark': 'Dark mode',
//   },
//   AppLang.my: {
//     'title': 'ကျွန်ုပ်၏ လုပ်စရာများ',
//     'hint': 'ဘာလုပ်ရမလဲ?',
//     'add': 'ထည့်ရန်',
//     'empty': 'လုပ်စရာ မရှိသေးပါ။ ပထမဆုံးတစ်ခု ထည့်လိုက်ပါ!',
//     'pending': 'ကျန်သည်',
//     'done': 'ပြီးပြီ',
//     'clearDone': 'ပြီးသားများကို ဖယ်ရှားရန်',
//     'language': 'English',
//     'dark': 'အမှောင်မုဒ်',
//   },
// };

// class Todo {
//   Todo(this.text, {this.done = false});
//   String text;
//   bool done;
// }

// class TodoApp extends StatefulWidget {
//   const TodoApp({super.key});

//   @override
//   State<TodoApp> createState() => _TodoAppState();
// }

// class _TodoAppState extends State<TodoApp> {
//   AppLang _lang = AppLang.en;
//   bool _dark = false;

//   @override
//   Widget build(BuildContext context) {
//     // Forui does not switch light/dark automatically; choose explicitly.
//     final theme = _dark ? FTheme.neutral.dark.touch : FTheme.neutral.light.touch;

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       locale: Locale(_lang.name),
//       supportedLocales: FLocalizations.supportedLocales,
//       localizationsDelegates: const [...FLocalizations.localizationsDelegates],
//       builder: (context, child) => FTheme(data: theme, child: child!),
//       home: FScaffold(
//         child: TodoPage(
//           lang: _lang,
//           dark: _dark,
//           onToggleLang: () => setState(
//             () => _lang = _lang == AppLang.en ? AppLang.my : AppLang.en,
//           ),
//           onToggleDark: (v) => setState(() => _dark = v),
//         ),
//       ),
//     );
//   }
// }

// class TodoPage extends StatefulWidget {
//   const TodoPage({
//     super.key,
//     required this.lang,
//     required this.dark,
//     required this.onToggleLang,
//     required this.onToggleDark,
//   });

//   final AppLang lang;
//   final bool dark;
//   final VoidCallback onToggleLang;
//   final ValueChanged<bool> onToggleDark;

//   @override
//   State<TodoPage> createState() => _TodoPageState();
// }

// class _TodoPageState extends State<TodoPage> {
//   final _controller = TextEditingController();
//   final List<Todo> _todos = [
//     Todo('Buy groceries'),
//     Todo('ဈေးဝယ်သွားရန်'),
//     Todo('Read a book', done: true),
//   ];

//   String t(String key) => _strings[widget.lang]![key]!;

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void _add() {
//     final text = _controller.text.trim();
//     if (text.isEmpty) return;
//     setState(() => _todos.insert(0, Todo(text)));
//     _controller.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final pending = _todos.where((e) => !e.done).length;
//     final done = _todos.length - pending;

//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Row(
//               children: [
//                 const Icon(FLucideIcons.listTodo, size: 28),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     t('title'),
//                     style: const TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 FButton(
//                   prefix: const Icon(FLucideIcons.languages),
//                   onPress: widget.onToggleLang,
//                   child: Text(t('language')),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),

//             FSwitch(
//               label: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(widget.dark ? FLucideIcons.moon : FLucideIcons.sun, size: 18),
//                   const SizedBox(width: 8),
//                   Text(t('dark')),
//                 ],
//               ),
//               value: widget.dark,
//               onChange: widget.onToggleDark,
//             ),
//             const SizedBox(height: 16),

//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: FTextField(
//                     control: .managed(controller: _controller),
//                     hint: t('hint'),
//                     onSubmit: (_) => _add(),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 FButton(
//                   prefix: const Icon(FLucideIcons.plus),
//                   onPress: _add,
//                   child: Text(t('add')),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             Row(
//               children: [
//                 const Icon(FLucideIcons.clock, size: 16),
//                 const SizedBox(width: 6),
//                 Text('${t('pending')}: $pending'),
//                 const SizedBox(width: 16),
//                 const Icon(FLucideIcons.circleCheck, size: 16),
//                 const SizedBox(width: 6),
//                 Text('${t('done')}: $done'),
//               ],
//             ),
//             const SizedBox(height: 12),

//             Expanded(
//               child: _todos.isEmpty
//                   ? Center(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(FLucideIcons.clipboardList, size: 48),
//                           const SizedBox(height: 12),
//                           Text(t('empty')),
//                         ],
//                       ),
//                     )
//                   : ListView.separated(
//                       itemCount: _todos.length,
//                       separatorBuilder: (_, _) => const SizedBox(height: 8),
//                       itemBuilder: (context, i) {
//                         final todo = _todos[i];
//                         return FCard(
//                           child: Row(
//                             children: [
//                               FCheckbox(
//                                 value: todo.done,
//                                 onChange: (v) => setState(() => todo.done = v),
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Text(
//                                   todo.text,
//                                   style: TextStyle(
//                                     decoration: todo.done
//                                         ? TextDecoration.lineThrough
//                                         : null,
//                                   ),
//                                 ),
//                               ),
//                               FButton.icon(
//                                 onPress: () =>
//                                     setState(() => _todos.remove(todo)),
//                                 child: const Icon(FLucideIcons.trash2),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//             ),

//             if (done > 0) ...[
//               const SizedBox(height: 8),
//               FButton(
//                 prefix: const Icon(FLucideIcons.trash2),
//                 onPress: () => setState(() => _todos.removeWhere((e) => e.done)),
//                 child: Text(t('clearDone')),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
