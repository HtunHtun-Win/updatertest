import 'package:flutter/material.dart';
import 'package:flutter_desktop_updater/flutter_desktop_updater.dart';
import 'package:forui/forui.dart';

class Updatescreen extends StatefulWidget {
  const new({super.key});

  @override
  State<Updatescreen> createState() => _UpdatescreenState();
}

class _UpdatescreenState extends State<Updatescreen> {
  @override
  void initState() {
    super.initState();
    // Check for updates when app starts
    UpdateManager().checkForUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      child: Column(children: [Material(child: const UpdateBanner())]),
    );
  }
}
