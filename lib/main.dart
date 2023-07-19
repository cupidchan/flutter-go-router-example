import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_router_example/router/app_router.dart';
import 'package:flutter_router_example/services/app_service.dart';
import 'package:flutter_router_example/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
  runApp(MyApp(sharedPreferences: sharedPreferences));
}

class MyApp extends StatefulWidget {
  final SharedPreferences sharedPreferences;
  const MyApp({
    Key? key,
    required this.sharedPreferences,
  }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppService appService;
  late AuthService authService;
  late StreamSubscription<bool> authSubscription;

  @override
  void initState() {
    appService = AppService(widget.sharedPreferences);
    authService = AuthService();
    authSubscription = authService.onAuthStateChange.listen(onAuthStateChange);
    super.initState();
  }

  void onAuthStateChange(bool login) {
    appService.loginState = login;
  }

  @override
  void dispose() {
    authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Enabling the ChangeNotifier "appService" to notifyListeners()
        ChangeNotifierProvider<AppService>(create: (_) => appService),

        // A Provider of the AppRoute(appService) object (note that this object is annoymous and not stored as a variable in the app), which can be retrieved when someone calls Provider.of<AppRouter>(context)
        Provider<AppRouter>(create: (_) => AppRouter(appService)),

        // A Provider the authService object (different from the AppRouter above, this object is defined as a named variable in this app), which can be retrieved when someone calls Provider.of<AuthService>(context);
        Provider<AuthService>(create: (_) => authService),
      ],
      child: Builder(
        builder: (context) {
          // This is the receiving side of the above `Provider<AppRouter>(create: (_) => AppRouter(appService))` in MultiProvider. The we can call .router to retrieve the goRouter defined in the AppRouter class.
          final GoRouter goRouter =
              Provider.of<AppRouter>(context, listen: false).router;
          return MaterialApp.router(
            title: "Router App",
            routerConfig: goRouter,
          );
        },
      ),
    );
  }
}
