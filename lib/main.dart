import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:katya/context/storage.dart';
import 'package:katya/context/types.dart';
import 'package:katya/global/platform.dart';
import 'package:katya/global/values.dart';
import 'package:katya/providers/matrix_provider.dart';
import 'package:katya/providers/web3_provider.dart';
import 'package:katya/services/initialization/app_initialization_service.dart';
import 'package:katya/views/auth/matrix_login_screen.dart';
import 'package:katya/views/home/chat/matrix_chat_screen.dart';
import 'package:katya/views/home/matrix_rooms_screen.dart';
import 'package:katya/views/main_app_screen.dart';
import 'package:katya/views/prelock.dart';
import 'package:katya/theme/theme.dart';
import 'package:provider/provider.dart';

// ignore: avoid_void_async
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init platform specific code
  await initPlatformDependencies();

  // pull current context / nullable
  await loadContextCurrent();

  // Initialize app services
  try {
    await AppInitializationService().initializeApp();
  } catch (e) {
    print('Warning: App initialization failed: $e');
    // Continue with app startup even if initialization fails
  }

  if (SHOW_BORDERS && DEBUG_MODE) {
    debugPaintSizeEnabled = SHOW_BORDERS;
  }

  // init app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Web3Provider()..init()),
        ChangeNotifierProvider(create: (_) => MatrixProvider()..initialize()),
      ],
      child: const KatyaApp(
        prelockContext: null, // Will be set by Prelock
      ),
    ),
  );
}

class KatyaApp extends StatelessWidget {
  final dynamic prelockContext;

  const KatyaApp({
    super.key,
    required this.prelockContext,
  });

  @override
  Widget build(BuildContext context) {
    // Check if we need to show the prelock screen
    final shouldShowPrelock = prelockContext?.id?.isNotEmpty == true && prelockContext?.pinHash?.isNotEmpty == true;

    if (shouldShowPrelock) {
      return Prelock(
        appContext: prelockContext as AppContext,
        enabled: true,
      );
    }

    // Otherwise, show the main app with Matrix auth flow
    return MaterialApp(
      title: 'Katya',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: Consumer<MatrixProvider>(
        builder: (context, matrixProvider, _) {
          // Show loading indicator while initializing
          if (matrixProvider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Show login screen if not authenticated
          if (!matrixProvider.isLoggedIn) {
            return const MatrixLoginScreen();
          }

          // Show the main app with bottom navigation
          return const MainAppScreen();
        },
      ),
      routes: {
        '/login': (context) => const MatrixLoginScreen(),
        '/rooms': (context) => const MatrixRoomsScreen(),
        '/home': (context) => const MainAppScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle dynamic routes like /chat/:roomId
        if (settings.name?.startsWith('/chat/') == true) {
          final roomId = settings.name?.replaceFirst('/chat/', '');
          if (roomId != null && roomId.isNotEmpty) {
            return MaterialPageRoute(
              builder: (context) => MatrixChatScreen(roomId: roomId),
            );
          }
        }
        return null;
      },
    );
  }
}
