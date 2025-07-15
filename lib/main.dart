import 'package:app_v2ray_manager/providers/logs_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/v2ray_provider.dart';
import 'providers/settings_provider.dart';
import 'theme/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Create provider instances
  final v2rayProvider = V2RayProvider();
  final logsProvider = LogsProvider();

  // Wire up the callbacks
  v2rayProvider.setLogCallback(logsProvider.addLog);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: v2rayProvider),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: logsProvider),
      ],
      child: const V2RayManagerApp(),
    ),
  );
}
