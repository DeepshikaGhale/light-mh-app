import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'theme/obs_theme.dart';
import 'screens/burnout/burnout_home.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const LightApp(),
    ),
  );
}

class LightApp extends StatelessWidget {
  const LightApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return MaterialApp(
      title: 'Light',
      theme: ObsTheme.lightTheme,
      darkTheme: ObsTheme.darkTheme,
      themeMode: state.themeMode,
      debugShowCheckedModeBanner: false,
      home: const BurnoutHome(),
    );
  }
}
