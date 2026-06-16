import 'package:ev_connect_india/config/app_config.dart';
import 'package:ev_connect_india/config/routes.dart';
import 'package:ev_connect_india/providers/auth_provider.dart';
import 'package:ev_connect_india/providers/theme_provider.dart';
import 'package:ev_connect_india/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // Run app
  runApp(
    const ProviderScope(
      child: EVConnectIndiaApp(),
    ),
  );
}

class EVConnectIndiaApp extends ConsumerStatefulWidget {
  const EVConnectIndiaApp({super.key});

  @override
  ConsumerState<EVConnectIndiaApp> createState() => _EVConnectIndiaAppState();
}

class _EVConnectIndiaAppState extends ConsumerState<EVConnectIndiaApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize theme
    ref.read(themeProvider.notifier).initialize();

    // Check auth state
    ref.read(authProvider.notifier).checkAuthState();

    // Setup Firebase analytics
    _setupAnalytics();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _setupAnalytics() {
    // Analytics disabled in config
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Analytics disabled in config
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    final router = appRouter(ref);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Router
      routerConfig: router,

      // Localization
      locale: const Locale('en', 'IN'),

      // Scaffold messenger for global snackbar
      scaffoldMessengerKey: scaffoldMessengerKey,

      // Builder for media query override
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        final scale = mediaQueryData.textScaleFactor.clamp(0.8, 1.3);

        return MediaQuery(
          data: mediaQueryData.copyWith(textScaleFactor: scale),
          child: child!,
        );
      },
    );
  }
}

// Production Firebase options from GoogleService-Info.plist
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        return const FirebaseOptions(
          apiKey: 'AIzaSyA17YhTv6l2cjy7VHE9g0vcpGwcymlPPvo',
          appId: '1:581584527896:ios:d892530b7265fd2bc3196d',
          messagingSenderId: '581584527896',
          projectId: 'ev-charging-station-e2fe8',
          storageBucket: 'ev-charging-station-e2fe8.firebasestorage.app',
          iosBundleId: 'com.evconnectindia.app',
        );
      default:
        return const FirebaseOptions(
          apiKey: 'AIzaSyA17YhTv6l2cjy7VHE9g0vcpGwcymlPPvo',
          appId: '1:581584527896:ios:d892530b7265fd2bc3196d',
          messagingSenderId: '581584527896',
          projectId: 'ev-charging-station-e2fe8',
          storageBucket: 'ev-charging-station-e2fe8.firebasestorage.app',
          iosBundleId: 'com.evconnectindia.app',
        );
    }
  }
}
