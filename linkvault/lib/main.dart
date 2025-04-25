import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkvault/providers/auth_provider.dart';

import 'package:linkvault/services/connectivity_services.dart';
import 'package:linkvault/utils/theme.dart';
import 'package:linkvault/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await ConnectivityService.initialize();

  final container = ProviderContainer();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'LinkVault',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
