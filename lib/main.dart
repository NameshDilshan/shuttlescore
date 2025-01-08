import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shuttlescore/screens/login_screen.dart';
import 'package:shuttlescore/screens/splash_screen.dart';
import 'package:shuttlescore/theme/app_colors.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return
      // MultiProvider(
      // providers: [
      //   ChangeNotifierProvider(create: (_) => ExerciseProvider()),
      //   ChangeNotifierProvider(
      //     create: (_) {
      //       final userProvider = UserProvider();
      //       userProvider.loadUserFromPreferences(); // Load the user session on app start
      //       return userProvider;
      //     },
      //   ),
      // ],
      // child:
    MaterialApp(
        title: 'Shuttle Score',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Roboto',
        ),
        routes: {
          '/': (context) => SplashScreen(),
          '/login': (context) => LoginScreen(),
          // '/home': (context) => const HomeScreen(),
        },
      // ),
    );
  }
}
