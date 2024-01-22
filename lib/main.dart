import 'package:flutter/services.dart';
//import 'package:splash_screen_view/SplashScreenView.dart';
//import 'package:splashscreen/splashscreen.dart';
import 'package:splash_view/splash_view.dart';
import 'package:theme_mode_builder/theme_mode_builder.dart';
import 'auth_gate.dart';
import '../../../utils/imports.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeModeBuilderConfig.ensureInitialized(
    subDir: "Theme Mode Builder Example",
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return ThemeModeBuilder(
        builder: (BuildContext context, ThemeMode themeMode) {
      return MaterialApp(
        home: SplashView(
          logo: Text("assets/app_logo.png"),
          done: Done(AuthGate()),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.black,
        ),
        debugShowCheckedModeBanner: false,
      );
    });
  }
}
